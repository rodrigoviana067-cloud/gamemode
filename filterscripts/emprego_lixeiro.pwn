#include <a_samp>
#include <zcmd>
#include <dini>

new PlayerJob[MAX_PLAYERS];
new Trabalhando[MAX_PLAYERS];
new LixoAtual[MAX_PLAYERS];

// Definições de uniforme (Skin de lixeiro)
#define SKIN_LIXEIRO 281 // exemplo: caminhoneiro/operário

#define EMPREGO_NENHUM 0
#define EMPREGO_LIXEIRO 1
#define MAX_LIXO_PONTOS 3
#define LIXO_VEHICLE 408 // Trashmaster

new LixoTruck;
new Float:LixoPontos[MAX_LIXO_PONTOS][3] =
{
    {2190.0, -1970.0, 13.5},
    {2150.0, -1940.0, 13.5},
    {2100.0, -1900.0, 13.5}
};

// =========================
// INIT
// =========================
public OnFilterScriptInit()
{
    print("Emprego Lixeiro carregado.");

    LixoTruck = CreateVehicle(
        LIXO_VEHICLE,
        2195.0, -1975.0, 13.5,
        90.0,
        1, 1,
        -1
    );

    return 1;
}

public OnPlayerConnect(playerid)
{
    new path[64], emprego;
    GetPlayerName(playerid, path, sizeof(path));
    format(path, sizeof(path), "Contas/%s.ini", path);

    // Carrega emprego salvo se existir
    if (dini_Exists(path))
    {
        emprego = dini_Int(path, "Emprego");
        PlayerJob[playerid] = emprego;
    }
    else
    {
        PlayerJob[playerid] = EMPREGO_NENHUM;
    }

    Trabalhando[playerid] = 0;
    LixoAtual[playerid] = 0;

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    new path[64], money;
    GetPlayerName(playerid, path, sizeof(path));
    format(path, sizeof(path), "Contas/%s.ini", path);

    // Salva dinheiro
    money = GetPlayerMoney(playerid);
    dini_IntSet(path, "Dinheiro", money);

    // Salva emprego
    dini_IntSet(path, "Emprego", PlayerJob[playerid]);

    return 1;
}

// =========================
// CHECKPOINT
// =========================
public OnPlayerEnterCheckpoint(playerid)
{
    if (!Trabalhando[playerid]) return 1;

    if (!IsPlayerInVehicle(playerid, LixoTruck))
    {
        SendClientMessage(playerid, -1, "Volte para o caminhão de lixo.");
        return 1;
    }

    GivePlayerMoney(playerid, 300);

    LixoAtual[playerid]++;

    if (LixoAtual[playerid] >= MAX_LIXO_PONTOS)
    {
        DisablePlayerCheckpoint(playerid);
        Trabalhando[playerid] = 0;
        SendClientMessage(playerid, -1, "Trabalho finalizado! Bom serviço.");
        return 1;
    }

    SetPlayerCheckpoint(
        playerid,
        LixoPontos[LixoAtual[playerid]][0],
        LixoPontos[LixoAtual[playerid]][1],
        LixoPontos[LixoAtual[playerid]][2],
        4.0
    );

    SendClientMessage(playerid, -1, "Lixo coletado! Próximo ponto marcado.");
    return 1;
}

// =========================
// PEGAR EMPREGO
// =========================
CMD:pegarlixo(playerid, params[])
{
    PlayerJob[playerid] = EMPREGO_LIXEIRO;
    LixoAtual[playerid] = 0;
    Trabalhando[playerid] = 0;

    SendClientMessage(playerid, -1, "Você agora é um LIXEIRO!");
    SendClientMessage(playerid, -1, "Use /iniciarlixo para trabalhar.");
    return 1;
}

// =========================
// INICIAR TRABALHO
// =========================
CMD:iniciarlixo(playerid, params[])
{
    if (PlayerJob[playerid] != EMPREGO_LIXEIRO)
        return SendClientMessage(playerid, -1, "Você não é lixeiro.");

    if (!IsPlayerInVehicle(playerid, LixoTruck))
        return SendClientMessage(playerid, -1, "Você precisa estar no caminhão de lixo.");

    Trabalhando[playerid] = 1;
    LixoAtual[playerid] = 0;

    // Aplica uniforme
    SetPlayerSkin(playerid, SKIN_LIXEIRO);

    SetPlayerCheckpoint(
        playerid,
        LixoPontos[0][0],
        LixoPontos[0][1],
        LixoPontos[0][2],
        4.0
    );

    SendClientMessage(playerid, -1, "Trabalho iniciado. Siga os pontos.");
    return 1;
}

// =========================
// TRABALHAR (comando extra)
// =========================
CMD:trabalhar(playerid, params[])
{
    if (PlayerJob[playerid] != EMPREGO_LIXEIRO)
        return SendClientMessage(playerid, -1, "Você não é lixeiro.");

    GivePlayerMoney(playerid, 500);
    SendClientMessage(playerid, -1, "Você trabalhou e ganhou $500.");
    return 1;
}

// =========================
// SAIR DO EMPREGO
// =========================
CMD:sairdoemprego(playerid, params[])
{
    PlayerJob[playerid] = EMPREGO_NENHUM;
    Trabalhando[playerid] = 0;
    DisablePlayerCheckpoint(playerid);

    // Retorna skin padrão (pode ser ajustada conforme preferir)
    SetPlayerSkin(playerid, 0); 

    SendClientMessage(playerid, -1, "Você saiu do emprego.");
    return 1;
}

// =========================
// CANCELAR SE SAIR DO CAMINHÃO
// =========================
public OnPlayerExitVehicle(playerid, vehicleid)
{
    if (vehicleid == LixoTruck && Trabalhando[playerid])
    {
        Trabalhando[playerid] = 0;
        DisablePlayerCheckpoint(playerid);
        SendClientMessage(playerid, -1, "Você saiu do caminhão. Trabalho cancelado.");
    }
    return 1;
}
