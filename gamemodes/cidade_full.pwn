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
// DIALOG RESPONSE (ÚNICO)
// =================================================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext))
        return 1;

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    // ================= LOGIN =================
    if (dialogid == DIALOG_LOGIN)
    {
        if (!response)
        {
            Kick(playerid);
            return 1;
        }

        new senha[32] = "";
        dini_Get(path, "Senha", senha, sizeof(senha));

        if (strcmp(inputtext, senha, false) != 0)
        {
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
                "Login",
                "Senha incorreta, tente novamente:",
                "Entrar", "Sair");
            return 1;
        }

        // LOGIN OK
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
        if (!response)
        {
            Kick(playerid);
            return 1;
        }

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

    return 0;
}

// =================================================
// PLAYER SPAWN
// =================================================
public OnPlayerSpawn(playerid)
{
    new path[64];
    ContaPath(playerid, path, sizeof(path));

    // Spawn global salvo por admin, ou padrão LSIA
    if (dini_Exists("spawn.ini"))
    {
        SetPlayerPos(
            playerid,
            dini_Float("spawn.ini", "X"),
            dini_Float("spawn.ini", "Y"),
            dini_Float("spawn.ini", "Z")
        );
        SetPlayerFacingAngle(playerid, dini_Float("spawn.ini", "A"));
    }
    else
    {
        // Ponto padrão no Aeroporto de Los Santos
        SetPlayerPos(playerid, -1257.5, -2704.9, 56.7);
        SetPlayerFacingAngle(playerid, 0.0);
    }

    // Skin salva na conta ou default
    if (dini_Exists(path))
        SetPlayerSkin(playerid, dini_Int(path, "Skin"));
    else
        SetPlayerSkin(playerid, 60);

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);

    return 1;
}
