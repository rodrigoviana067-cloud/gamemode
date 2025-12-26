#include <a_samp>

public OnGameModeInit()
{
    print("Gamemode iniciado!");
    SetGameModeText("Cidade RP Full");

    AddPlayerClass(
        0,          // skin
        1958.3783,  // x
        1343.1572,  // y
        15.3746,    // z
        269.0,      // angle
        0,0,0,0,0,0
    );

    return 1;
}

public OnPlayerConnect(playerid)
{
    printf("Player conectado: %d", playerid);
    return 1;
}

public OnPlayerSpawn(playerid)
{
    SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
    SetPlayerFacingAngle(playerid, 269.0);
    SetCameraBehindPlayer(playerid);
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (strcmp(cmdtext, "/dinheiro", true) == 0)
    {
        new money = GetPlayerMoney(playerid);
        new msg[64];
        format(msg, sizeof(msg), "Seu dinheiro: $%d", money);
        SendClientMessage(playerid, 0xFFFFFFFF, msg);
        return 1;
    }
    return 0;
}
