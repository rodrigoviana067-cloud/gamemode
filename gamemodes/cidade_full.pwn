#define _RATIONAL      // Ativa suporte a floats
#include <a_samp.inc>

// --------------------------------------------------
// Forwards
// --------------------------------------------------
forward OnGameModeInit();
forward OnGameModeExit();
forward OnPlayerConnect(playerid);
forward OnPlayerDisconnect(playerid, reason);
forward CMD_empregos(playerid, params[]);
forward CMD_pegartrabalho(playerid, params[]);
forward CMD_meuemprego(playerid, params[]);
forward CMD_comprarcarro(playerid, params[]);

// --------------------------------------------------
// Variáveis globais
// --------------------------------------------------

// --------------------------------------------------
// Gamemode init / exit
// --------------------------------------------------
public OnGameModeInit()
{
    SetGameModeText("Cidade RP Full");
    SetMaxPlayers(100);
    return 1;
}

public OnGameModeExit()
{
    return 1;
}

public OnPlayerConnect(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    SendClientMessage(playerid, 0xFFFFFFFF, "Bem-vindo(a) à Cidade RP!");
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    return 1;
}

// --------------------------------------------------
// Comandos básicos
// --------------------------------------------------
public CMD_empregos(playerid, params[])
{
    SendClientMessage(playerid, 0xFFFFFF00, "Lista de empregos: Motorista, Policial, Médico");
    return 1;
}

public CMD_pegartrabalho(playerid, params[])
{
    SendClientMessage(playerid, 0xFFFFFF00, "Você pegou o trabalho!");
    return 1;
}

public CMD_meuemprego(playerid, params[])
{
    SendClientMessage(playerid, 0xFFFFFF00, "Seu emprego atual: Motorista");
    return 1;
}

public CMD_comprarcarro(playerid, params[])
{
    SendClientMessage(playerid, 0xFFFFFF00, "Você comprou um carro!");
    return 1;
}

// --------------------------------------------------
// Função de spawn do jogador
// --------------------------------------------------
public OnPlayerRequestSpawn(playerid)
{
    PutPlayerInVehicle(playerid, 0, 0); // Spawn simples, sem veículo
    return 1;
}

// --------------------------------------------------
// Exemplo de função com float corrigida
// --------------------------------------------------
public CreateSpawnPoint(Float:x, Float:y, Float:z)
{
    spawnX = x;
    spawnY = y;
    spawnZ = z;
    return 1;
}
