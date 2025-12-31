main()
{
    print("Cidade RP Full carregada com sucesso");
}

#include <a_samp>
#include <zcmd>
#include <dini>

#include "cfg_constants.inc"
#include "player_data.inc"
#include "menus.inc"
#include "commands.inc"

public OnGameModeInit()
{
    SetGameModeText("Cidade RP Full");
    SetTimer("PagamentoSalario", 600000, true);
    return 1;
}

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

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (!response) return 1;

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    // ================= LOGIN =================
    if (dialogid == DIALOG_LOGIN)
    {
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

        // ✅ LOGIN OK
        Logado[playerid] = true;
        PlayerEmprego[playerid] = dini_Int(path, "Emprego");

        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);

        SendClientMessage(playerid, -1, "Login realizado com sucesso!");
        return 1;
    }

    // ================= REGISTRO =================
    if (dialogid == DIALOG_REGISTER)
    {
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

        Logado[playerid] = true;
        PlayerEmprego[playerid] = EMPREGO_NENHUM;

        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);

        SendClientMessage(playerid, -1, "Conta criada com sucesso!");
        return 1;
    }

    return 1;
}

// ================= SPAWN =================
public OnPlayerSpawn(playerid)
{
    SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
    SetPlayerFacingAngle(playerid, 0.0);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerSkin(playerid, SPAWN_SKIN);
    return 1;
}
