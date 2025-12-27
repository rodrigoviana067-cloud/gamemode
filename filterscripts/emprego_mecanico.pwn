#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <dini>

// ================= CONFIG =================
#define EMPREGO_NENHUM   0
#define EMPREGO_MECANICO 2

#define SKIN_MECANICO 50
#define PRECO_REPARO 1000
#define SALARIO_MECANICO 300

// Oficina LS
#define OFICINA_X 2065.0
#define OFICINA_Y -1831.0
#define OFICINA_Z 13.5

// ================= VARIÁVEIS ==============
new PlayerJob[MAX_PLAYERS];
new Trabalhando[MAX_PLAYERS];
new EmReparo[MAX_PLAYERS];
new OficinaCofre;

// ================= FUNÇÃO PATH ============
stock ContaPath(playerid, dest[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof nome);
    format(dest, size, "Contas/%s.ini", nome);
}

// ================= INIT ===================
public OnFilterScriptInit()
{
    if (!dini_Exists("dados/oficina.ini"))
    {
        dini_Create("dados/oficina.ini");
        dini_IntSet("dados/oficina.ini", "Cofre", 0);
    }

    OficinaCofre = dini_Int("dados/oficina.ini", "Cofre");
    print("Emprego Mecânico COMPLETO carregado.");
    return 1;
}

// ================= CONNECT =================
public OnPlayerConnect(playerid)
{
    new accpath[64];
    ContaPath(playerid, accpath, sizeof accpath);

    PlayerJob[playerid] = EMPREGO_NENHUM;
    Trabalhando[playerid] = 0;
    EmReparo[playerid] = 0;

    if (dini_Exists(accpath))
    {
        PlayerJob[playerid] = dini_Int(accpath, "Emprego");
        if (PlayerJob[playerid] == EMPREGO_MECANICO)
        {
            SetPlayerSkin(playerid, SKIN_MECANICO);
            SendClientMessage(playerid, -1, "Você entrou como MECÂNICO.");
        }
    }
    return 1;
}

// ================= PEGAR EMPREGO ==========
CMD:pegarmecanico(playerid, params[])
{
    new accpath[64];
    ContaPath(playerid, accpath, sizeof accpath);

    PlayerJob[playerid] = EMPREGO_MECANICO;
    SetPlayerSkin(playerid, SKIN_MECANICO);
    dini_IntSet(accpath, "Emprego", EMPREGO_MECANICO);

    SendClientMessage(playerid, -1, "Você agora é MECÂNICO.");
    return 1;
}

// ================= INICIAR SERVIÇO ========
CMD:iniciarmecanico(playerid, params[])
{
    if (PlayerJob[playerid] != EMPREGO_MECANICO)
        return SendClientMessage(playerid, -1, "Você não é mecânico.");

    if (!IsPlayerInRangeOfPoint(playerid, 5.0, OFICINA_X, OFICINA_Y, OFICINA_Z))
        return SendClientMessage(playerid, -1, "Vá até a oficina.");

    Trabalhando[playerid] = 1;
    SendClientMessage(playerid, -1, "Expediente iniciado.");
    return 1;
}

// ================= REPARAR =================
CMD:reparar(playerid, params[])
{
    if (!Trabalhando[playerid] || EmReparo[playerid])
        return SendClientMessage(playerid, -1, "Você não pode reparar agora.");

    new alvo;
    if (sscanf(params, "d", alvo))
        return SendClientMessage(playerid, -1, "/reparar [id]");

    if (!IsPlayerConnected(alvo))
        return SendClientMessage(playerid, -1, "Player inválido.");

    if (!IsPlayerInRangeOfPoint(playerid, 5.0, OFICINA_X, OFICINA_Y, OFICINA_Z))
        return SendClientMessage(playerid, -1, "Somente na oficina.");

    new veh = GetPlayerVehicleID(alvo);
    if (!veh)
        return SendClientMessage(playerid, -1, "Player não está em veículo.");

    if (GetPlayerMoney(alvo) < PRECO_REPARO)
        return SendClientMessage(playerid, -1, "Player sem dinheiro.");

    EmReparo[playerid] = 1;
    TogglePlayerControllable(playerid, 0);
    ApplyAnimation(playerid, "CAR", "Fixn_Car_Loop", 4.0, 1, 1, 1, 1, 0);

    GivePlayerMoney(alvo, -PRECO_REPARO);
    OficinaCofre += PRECO_REPARO;
    dini_IntSet("dados/oficina.ini", "Cofre", OficinaCofre);

    SetTimerEx("FinalizarReparo", 5000, false, "ii", playerid, veh);
    return 1;
}

forward FinalizarReparo(playerid, vehicleid);
public FinalizarReparo(playerid, vehicleid)
{
    RepairVehicle(vehicleid);
    ClearAnimations(playerid);
    TogglePlayerControllable(playerid, 1);
    EmReparo[playerid] = 0;

    GivePlayerMoney(playerid, SALARIO_MECANICO);
    SendClientMessage(playerid, -1, "Reparo concluído. Salário recebido.");
    return 1;
}

// ================= COFRE ADMIN ============
CMD:cofreoficina(playerid, params[])
{
    if (!IsPlayerAdmin(playerid)) return 1;

    new msg[64];
    format(msg, sizeof msg, "Cofre da oficina: $%d", OficinaCofre);
    SendClientMessage(playerid, -1, msg);
    return 1;
}
