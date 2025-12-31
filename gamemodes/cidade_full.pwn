#include <a_samp>
#include <zcmd>
#include <dini>

#include "cfg_constants.inc"
#include "player_data.inc"
#include "menus.inc"
#include "commands.inc"

// =================================================
// MAIN
// =================================================
main()
{
    print("Cidade RP Full carregada com sucesso");
}

// =================================================
// GAMEMODE INIT
// =================================================
public OnGameModeInit()
{
    SetGameModeText("Cidade RP Full");
    SetTimer("PagamentoSalario", 600000, true);
    return 1;
}

// =================================================
// PLAYER CONNECT
// =================================================
public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    PlayerEmprego[playerid] = EMPREGO_NENHUM;

    TogglePlayerControllable(playerid, false);

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    if (dini_Exists(path))
    {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
            "Login",
            "Digite sua senha:",
            "Entrar", "Sair");
    }
    else
    {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
            "Registro",
            "Crie sua senha:",
            "Registrar", "Sair");
    }
    return 1;
}

// =================================================
// DIALOG RESPONSE
// =================================================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new path[64];
    ContaPath(playerid, path, sizeof(path));

    // ================= LOGIN =================
    if (dialogid == DIALOG_LOGIN)
    {
        if (!response) return Kick(playerid);

        new senha[32];
        dini_Get(path, "Senha", senha);

        if (strcmp(inputtext, senha, false) != 0)
        {
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
                "Login",
                "Senha incorreta, tente novamente:",
                "Entrar", "Sair");
            return 1;
        }

        Logado[playerid] = true;
        PlayerEmprego[playerid] = dini_Int(path, "Emprego");

        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);
        SetCameraBehindPlayer(playerid);

        SendClientMessage(playerid, -1, "✅ Login realizado com sucesso!");
        return 1;
    }

    // ================= REGISTRO =================
    if (dialogid == DIALOG_REGISTER)
    {
        if (!response) return Kick(playerid);

        if (strlen(inputtext) < 3)
        {
            ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
                "Registro",
                "Senha muito curta (mín. 3 caracteres):",
                "Registrar", "Sair");
            return 1;
        }

        dini_Create(path);
        dini_Set(path, "Senha", inputtext);
        dini_IntSet(path, "Emprego", EMPREGO_NENHUM);
        dini_IntSet(path, "Skin", 60);

        Logado[playerid] = true;
        PlayerEmprego[playerid] = EMPREGO_NENHUM;

        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);
        SetCameraBehindPlayer(playerid);

        SendClientMessage(playerid, -1, "✅ Conta criada com sucesso!");
        return 1;
    }

    // ================= OUTROS DIALOGS =================
    return HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext);
}

// =================================================
// PLAYER SPAWN (SEGURO)
// =================================================
public OnPlayerSpawn(playerid)
{
    if (!Logado[playerid])
        return 1;

    new Float:X, Float:Y, Float:Z, Float:A;
    new path[64];
    ContaPath(playerid, path, sizeof(path));

    if (dini_Exists("spawn.ini"))
    {
        X = dini_Float("spawn.ini", "X");
        Y = dini_Float("spawn.ini", "Y");
        Z = dini_Float("spawn.ini", "Z");
        A = dini_Float("spawn.ini", "A");

        SetPlayerPos(playerid, X, Y, Z);
        SetPlayerFacingAngle(playerid, A);
    }

    if (dini_Exists(path))
    {
        SetPlayerSkin(playerid, dini_Int(path, "Skin"));
    }

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    return 1;
}
