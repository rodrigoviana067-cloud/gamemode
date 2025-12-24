#include <a_samp>
#include <core>
#include <zcmd>
#include <sscanf2>

#define COR_BRANCO 0xFFFFFFFF

public OnGameModeInit()
{
    print("CIDADE NOVA RP carregado!");
    SetGameModeText("CIDADE NOVA RP");
    return 1;
}

public OnPlayerConnect(playerid)
{
    SendClientMessage(playerid, COR_BRANCO, "Bem-vindo a CIDADE NOVA RP!");
    return 1;
}

