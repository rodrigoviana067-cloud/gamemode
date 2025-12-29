#include <a_samp>
#include <zcmd>
#include <dini>

#include "cfg_constants.inc"
#include "player_data.inc"
#include "menus.inc"
#include "commands.inc"

forward PagamentoSalario();
public PagamentoSalario()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Logado[i] && PlayerEmprego[i] != EMPREGO_NENHUM)
        {
            GivePlayerMoney(i, 1000);
            SendClientMessage(i, 0x00FF00FF, "Salário recebido.");
        }
    }
    return 1;
}

public OnGameModeInit()
{
    SetGameModeText("Cidade RP Full");
    SetTimer("PagamentoSalario", 600000, true);
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if(!success)
    {
        SendClientMessage(playerid, 0xFF4444FF,
            "Comando inválido! Use /menu ou /ajuda para ver todos os comandos disponíveis.");
        return 1;
    }
    return 1;
}

public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    PlayerEmprego[playerid] = EMPREGO_NENHUM;
    TogglePlayerControllable(playerid, false);

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    if(dini_Exists(path))
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
            "Login", "Digite sua senha:", "Entrar", "Sair");
    else
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
            "Registro", "Crie sua senha:", "Registrar", "Sair");

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(!Logado[playerid]) return 1;

    new path[64];
    ContaPath(playerid, path, sizeof(path));
    dini_IntSet(path, "Emprego", PlayerEmprego[playerid]);
    return 1;
}

public OnPlayerSpawn(playerid)
{
    SetPlayerSkin(playerid, SPAWN_SKIN);
    SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    return 1;
}
