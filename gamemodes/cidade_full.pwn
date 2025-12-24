#include <a_samp>
#include <zcmd>
#include <sscanf2>

new Float:spawnX[MAX_PLAYERS];
new Float:spawnY[MAX_PLAYERS];
new Float:spawnZ[MAX_PLAYERS];
new playerName[MAX_PLAYERS][MAX_PLAYER_NAME + 1];

forward CMD_empregos(playerid, params[]);
forward CMD_pegartrabalho(playerid, params[]);
forward CMD_meuemprego(playerid, params[]);
forward CMD_comprarcarro(playerid, params[]);

public OnGameModeInit()
{
    SetGameModeText("Cidade RP Full");
    SetTeamCount(0);
    // Aqui você pode adicionar spawn points fixos, veículos, pickups etc.
    return 1;
}

public OnPlayerConnect(playerid)
{
    GetPlayerName(playerid, playerName[playerid], sizeof(playerName[]));
    spawnX[playerid] = 0.0;
    spawnY[playerid] = 0.0;
    spawnZ[playerid] = 3.0; // spawn default
    return 1;
}

public OnPlayerRequestSpawn(playerid)
{
    PutPlayerInVehicle(playerid, 0, 0);
    SetPlayerPos(playerid, spawnX[playerid], spawnY[playerid], spawnZ[playerid]);
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    return 1;
}

// Comandos
CMD_empregos(playerid, params[])
{
    SendClientMessage(playerid, 0xFFFFFFFF, "Lista de empregos: Motorista, Policial, Médico.");
    return 1;
}

CMD_pegartrabalho(playerid, params[])
{
    SendClientMessage(playerid, 0xFFFFFFFF, "Você pegou um emprego!");
    return 1;
}

CMD_meuemprego(playerid, params[])
{
    SendClientMessage(playerid, 0xFFFFFFFF, "Seu emprego atual: Nenhum");
    return 1;
}

CMD_comprarcarro(playerid, params[])
{
    SendClientMessage(playerid, 0xFFFFFFFF, "Você comprou um carro!");
    return 1;
}

// Outras callbacks
public OnPlayerDisconnect(playerid, reason)
{
    return 1;
}

public OnPlayerSpawn(playerid)
{
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    return 1;
}

public OnGameModeExit()
{
    return 1;
}

public OnPlayerText(playerid, text[])
{
    return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    return 1;
}

// Adicione aqui outros forwards que você precise
