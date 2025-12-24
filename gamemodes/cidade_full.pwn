#include <a_samp>
#include <zcmd>
#include <sscanf2>

forward OnGameModeInit();
forward OnPlayerConnect(playerid);
forward OnPlayerRequestSpawn(playerid);
forward OnPlayerCommandText(playerid, cmdtext[]);

public OnGameModeInit() {
    print("Gamemode iniciado!");
    SetMaxPlayers(100); // Exemplo
    SetGameModeText("Cidade RP Full");
    SetTeamCount(0);
    return 1;
}

public OnPlayerConnect(playerid) {
    print("Player conectado: %d", playerid);
    return 1;
}

public OnPlayerRequestSpawn(playerid) {
    Float:x = 0.0, y = 0.0, z = 3.0;
    AddPlayerClass(0, x, y, z, 0.0, 0,0,0,0,0,0);
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(strcmp(cmdtext, "/meu dinheiro", true) == 0) {
        new money = GetPlayerMoney(playerid);
        SendClientMessage(playerid, 0xFFFFFFFF, "Seu dinheiro: $%d", money);
        return 1;
    }
    return 0;
}
