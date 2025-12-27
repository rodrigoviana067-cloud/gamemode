#include <a_samp>
#include <zcmd>

#define EMPREGO_NENHUM 0
#define EMPREGO_LIXEIRO 1

new PlayerJob[MAX_PLAYERS];

// =========================
// INIT
// =========================
public OnFilterScriptInit()
{
    print("Emprego Lixeiro carregado.");
    return 1;
}

public OnPlayerConnect(playerid)
{
    PlayerJob[playerid] = EMPREGO_NENHUM;
    return 1;
}

// =========================
// PEGAR EMPREGO
// =========================
CMD:pegarlixo(playerid, params[])
{
    PlayerJob[playerid] = EMPREGO_LIXEIRO;
    SendClientMessage(playerid, -1, "Você agora é um LIXEIRO!");
    return 1;
}

// =========================
// TRABALHAR
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
    SendClientMessage(playerid, -1, "Você saiu do emprego.");
    return 1;
}
