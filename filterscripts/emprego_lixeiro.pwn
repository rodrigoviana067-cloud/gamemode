#include <a_samp>
#include <zcmd>

#define EMPREGO_NENHUM 0
#define EMPREGO_LIXEIRO 1
#define MAX_LIXO_PONTOS 3

new Float:LixoPontos[MAX_LIXO_PONTOS][3] =
{
    {2190.0, -1970.0, 13.5},
    {2150.0, -1940.0, 13.5},
    {2100.0, -1900.0, 13.5}
};

new LixoAtual[MAX_PLAYERS];
new Trabalhando[MAX_PLAYERS];

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
public OnPlayerEnterCheckpoint(playerid)
{
    if (!Trabalhando[playerid]) return 1;

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
        3.0
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

CMD:iniciarlixo(playerid, params[])
{
    if (PlayerJob[playerid] != EMPREGO_LIXEIRO)
        return SendClientMessage(playerid, -1, "Você não é lixeiro.");

    Trabalhando[playerid] = 1;
    LixoAtual[playerid] = 0;

    SetPlayerCheckpoint(
        playerid,
        LixoPontos[0][0],
        LixoPontos[0][1],
        LixoPontos[0][2],
        3.0
    );

    SendClientMessage(playerid, -1, "Vá até o ponto de lixo marcado.");
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
    Trabalhando[playerid] = 0;
    DisablePlayerCheckpoint(playerid);

    SendClientMessage(playerid, -1, "Você saiu do emprego.");
    return 1;
}
