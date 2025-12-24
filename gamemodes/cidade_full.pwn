#include <a_samp>
#include <core>
#include <zcmd>
#include <sscanf2>

#define COR_VERDE 0x33AA33FF
#define COR_VERMELHO 0xAA3333FF
#define COR_BRANCO 0xFFFFFFFF
#define COR_AMARELO 0xFFFF00FF

// =====================
// VARIÁVEIS
// =====================
new PlayerJob[MAX_PLAYERS];

// =====================
// ENUM DE EMPREGOS
// =====================
enum
{
    EMPREGO_NENHUM,
    EMPREGO_MOTORISTA,
    EMPREGO_MECANICO
};

// =====================
// POSIÇÕES IMPORTANTES
// =====================
#define PREF_X 1481.0
#define PREF_Y -1771.0
#define PREF_Z 18.8

#define CONC_X 2131.0
#define CONC_Y -1150.0
#define CONC_Z 24.0

// =====================
// FILTERSCRIPT INIT
// =====================
public OnFilterScriptInit()
{
    print("====================================");
    print(" FilterScript CIDADE FULL carregado ");
    print("====================================");

    // Prefeitura
    Create3DTextLabel("{00FF00}Prefeitura\n{FFFFFF}/empregos", COR_BRANCO,
        PREF_X, PREF_Y, PREF_Z, 30.0, 0);

    CreatePickup(1239, 1, PREF_X, PREF_Y, PREF_Z);

    // Concessionária
    Create3DTextLabel("{00FF00}Concessionária\n{FFFFFF}/comprarcarro", COR_BRANCO,
        CONC_X, CONC_Y, CONC_Z, 30.0, 0);

    CreatePickup(1274, 1, CONC_X, CONC_Y, CONC_Z);

    return 1;
}

public OnFilterScriptExit()
{
    print("FilterScript CIDADE FULL descarregado.");
    return 1;
}

// =====================
// PLAYER CONNECT
// =====================
public OnPlayerConnect(playerid)
{
    PlayerJob[playerid] = EMPREGO_NENHUM;
    SendClientMessage(playerid, COR_VERDE,
        "Bem-vindo ao servidor RP!");
    return 1;
}

// =====================
// COMANDOS
// =====================

// Ver empregos
CMD:empregos(playerid, params[])
{
    SendClientMessage(playerid, COR_AMARELO,
        "Empregos disponíveis:");
    SendClientMessage(playerid, COR_BRANCO,
        "1 - Motorista");
    SendClientMessage(playerid, COR_BRANCO,
        "2 - Mecânico");
    SendClientMessage(playerid, COR_BRANCO,
        "Use /pegartrabalho [id]");
    return 1;
}

// Pegar emprego
CMD:pegartrabalho(playerid, params[])
{
    new id;
    if(sscanf(params, "d", id))
        return SendClientMessage(playerid, COR_VERMELHO,
            "Uso: /pegartrabalho [id]");

    if(id < 1 || id > 2)
        return SendClientMessage(playerid, COR_VERMELHO,
            "Emprego inválido.");

    switch(id)
    {
        case 1:
        {
            PlayerJob[playerid] = EMPREGO_MOTORISTA;
            SendClientMessage(playerid, COR_VERDE,
                "Você agora é Motorista.");
        }
        case 2:
        {
            PlayerJob[playerid] = EMPREGO_MECANICO;
            SendClientMessage(playerid, COR_VERDE,
                "Você agora é Mecânico.");
        }
    }
    return 1;
}

// Comprar carro simples
CMD:comprarcarro(playerid, params[])
{
    if(GetPlayerMoney(playerid) < 5000)
        return SendClientMessage(playerid, COR_VERMELHO,
            "Você precisa de $5000.");

    GivePlayerMoney(playerid, -5000);
    new veh = CreateVehicle(411,
        GetPlayerPos(playerid),
        GetPlayerFacingAngle(playerid),
        -1, -1, -1);

    PutPlayerInVehicle(playerid, veh, 0);
    SendClientMessage(playerid, COR_VERDE,
        "Carro comprado com sucesso!");
    return 1;
}

// Meu emprego
CMD:meuemprego(playerid, params[])
{
    switch(PlayerJob[playerid])
    {
        case EMPREGO_NENHUM:
            SendClientMessage(playerid, COR_BRANCO,
                "Você não possui emprego.");
        case EMPREGO_MOTORISTA:
            SendClientMessage(playerid, COR_BRANCO,
                "Seu emprego: Motorista.");
        case EMPREGO_MECANICO:
            SendClientMessage(playerid, COR_BRANCO,
                "Seu emprego: Mecânico.");
    }
    return 1;
}
