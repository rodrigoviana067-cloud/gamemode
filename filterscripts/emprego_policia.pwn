#include <a_samp>
#include <zcmd>
#include <sscanf2>

// =======================
// DEFINES
// =======================
#define ORG_NENHUMA 0
#define ORG_PM 1

#define TAXA_ENTRADA_PM 50000

#define CARGO_RECRUTA   0
#define CARGO_SOLDADO   1
#define CARGO_CABO      2
#define CARGO_SARGENTO  3
#define CARGO_TENENTE   4
#define CARGO_CAPITAO   5
#define CARGO_CORONEL   6

// =======================
// VARIÁVEIS
// =======================
new Org[MAX_PLAYERS];
new Cargo[MAX_PLAYERS];
new EmServico[MAX_PLAYERS];
new Algemado[MAX_PLAYERS];
new PresoTempo[MAX_PLAYERS];

new CofrePM = 0;
new TimerPrisao[MAX_PLAYERS];

// =======================
// SALÁRIOS POR CARGO
// =======================
stock SalarioCargo(cargo)
{
    switch (cargo)
    {
        case CARGO_RECRUTA: return 500;
        case CARGO_SOLDADO: return 800;
        case CARGO_CABO: return 1100;
        case CARGO_SARGENTO: return 1500;
        case CARGO_TENENTE: return 2000;
        case CARGO_CAPITAO: return 3000;
        case CARGO_CORONEL: return 5000;
    }
    return 0;
}

// =======================
// INIT
// =======================
public OnFilterScriptInit()
{
    print("✔ Sistema de Polícia COMPLETO carregado.");
    return 1;
}

public OnPlayerConnect(playerid)
{
    Org[playerid] = ORG_NENHUMA;
    Cargo[playerid] = 0;
    EmServico[playerid] = 0;
    Algemado[playerid] = 0;
    PresoTempo[playerid] = 0;
    return 1;
}

// =======================
// ENTRAR NA PM
// =======================
CMD:entrarpm(playerid)
{
    if (Org[playerid] != ORG_NENHUMA)
        return SendClientMessage(playerid, -1, "Você já pertence a uma organização.");

    if (GetPlayerMoney(playerid) < TAXA_ENTRADA_PM)
        return SendClientMessage(playerid, -1, "Dinheiro insuficiente.");

    GivePlayerMoney(playerid, -TAXA_ENTRADA_PM);
    CofrePM += TAXA_ENTRADA_PM;

    Org[playerid] = ORG_PM;
    Cargo[playerid] = CARGO_RECRUTA;

    SendClientMessage(playerid, -1, "Você entrou na Polícia Militar como RECRUTA.");
    return 1;
}

// =======================
// SERVIÇO
// =======================
CMD:servico(playerid)
{
    if (Org[playerid] != ORG_PM)
        return SendClientMessage(playerid, -1, "Você não é policial.");

    EmServico[playerid] = !EmServico[playerid];

    if (EmServico[playerid])
    {
        SetPlayerSkin(playerid, 280);
        GivePlayerWeapon(playerid, 3, 1);
        SendClientMessage(playerid, -1, "Você entrou em serviço.");
    }
    else
    {
        ResetPlayerWeapons(playerid);
        SendClientMessage(playerid, -1, "Você saiu de serviço.");
    }
    return 1;
}

// =======================
// SALÁRIO
// =======================
CMD:salario(playerid)
{
    if (Org[playerid] != ORG_PM)
        return SendClientMessage(playerid, -1, "Você não é policial.");

    new valor = SalarioCargo(Cargo[playerid]);
    if (CofrePM < valor)
        return SendClientMessage(playerid, -1, "Cofre da PM sem fundos.");

    CofrePM -= valor;
    GivePlayerMoney(playerid, valor);

    SendClientMessage(playerid, -1, "Salário recebido.");
    return 1;
}

// =======================
// MULTAR
// =======================
CMD:multar(playerid, params[])
{
    new alvo, valor;
    if (sscanf(params, "ui", alvo, valor))
        return SendClientMessage(playerid, -1, "Use: /multar ID VALOR");

    if (Org[playerid] != ORG_PM)
        return 1;

    GivePlayerMoney(alvo, -valor);
    CofrePM += valor;

    SendClientMessage(alvo, -1, "Você foi multado.");
    SendClientMessage(playerid, -1, "Multa aplicada.");
    return 1;
}

// =======================
// ALGEMAR
// =======================
CMD:algemar(playerid, params[])
{
    new alvo;
    if (sscanf(params, "u", alvo))
        return SendClientMessage(playerid, -1, "Use: /algemar ID");

    if (!EmServico[playerid]) return 1;

    TogglePlayerControllable(alvo, 0);
    Algemado[alvo] = 1;

    SendClientMessage(alvo, -1, "Você foi algemado.");
    return 1;
}

CMD:desalgemar(playerid, params[])
{
    new alvo;
    if (sscanf(params, "u", alvo))
        return 1;

    TogglePlayerControllable(alvo, 1);
    Algemado[alvo] = 0;
    SendClientMessage(alvo, -1, "Você foi solto.");
    return 1;
}

// =======================
// PRENDER COM TEMPO
// =======================
forward PrisaoTick(playerid);
public PrisaoTick(playerid)
{
    PresoTempo[playerid]--;
    if (PresoTempo[playerid] <= 0)
    {
        KillTimer(TimerPrisao[playerid]);
        PresoTempo[playerid] = 0;

        SetPlayerInterior(playerid, 0);
        SetPlayerPos(playerid, 1550.0, -1675.0, 16.0);

        SendClientMessage(playerid, -1, "Você foi liberado da prisão.");
    }
    return 1;
}

CMD:prender(playerid, params[])
{
    new alvo, tempo;
    if (sscanf(params, "ui", alvo, tempo))
        return SendClientMessage(playerid, -1, "Use: /prender ID TEMPO");

    SetPlayerInterior(alvo, 6);
    SetPlayerPos(alvo, 264.0, 77.0, 1001.0);

    PresoTempo[alvo] = tempo;
    TimerPrisao[alvo] = SetTimerEx("PrisaoTick", 60000, true, "i", alvo);

    SendClientMessage(alvo, -1, "Você foi preso.");
    return 1;
}

// =======================
// PROMOVER / DEMITIR
// =======================
CMD:promover(playerid, params[])
{
    new alvo;
    if (sscanf(params, "u", alvo)) return 1;
    if (Cargo[playerid] < CARGO_TENENTE) return 1;

    Cargo[alvo]++;
    SendClientMessage(alvo, -1, "Você foi promovido.");
    return 1;
}

CMD:demitir(playerid, params[])
{
    new alvo;
    if (sscanf(params, "u", alvo)) return 1;
    if (Cargo[playerid] < CARGO_CAPITAO) return 1;

    Org[alvo] = ORG_NENHUMA;
    Cargo[alvo] = 0;

    SendClientMessage(alvo, -1, "Você foi expulso da PM.");
    return 1;
}
