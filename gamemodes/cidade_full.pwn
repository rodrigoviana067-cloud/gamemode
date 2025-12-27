#include <a_samp>
#include <dini>

#define DIALOG_LOGIN    1
#define DIALOG_REGISTER 2

new bool:Logado[MAX_PLAYERS];

// ================= MAIN =================
main()
{
    print("Gamemode cidade_full carregado.");
}

// ================= PATH =================
stock ContaPath(playerid, path[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof nome);
    format(path, size, "Contas/%s.ini", nome);
}

// ================= CONNECT =================
public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    ResetPlayerMoney(playerid);

    TogglePlayerControllable(playerid, false);

    new path[64];
    ContaPath(playerid, path, sizeof path);

    if(dini_Exists(path))
    {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
            "Login", "Digite sua senha:", "Entrar", "Sair");
    }
    else
    {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
            "Registro", "Crie uma senha:", "Registrar", "Sair");
    }
    return 1;
}

// ================= DIALOG =================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(!response) return Kick(playerid);

    new path[64];
    ContaPath(playerid, path, sizeof path);

    if(dialogid == DIALOG_REGISTER)
    {
        dini_Create(path);
        dini_Set(path, "Senha", inputtext);
        dini_IntSet(path, "Dinheiro", 500);
        dini_IntSet(path, "Admin", 0);

        dini_FloatSet(path, "X", 1958.3783);
        dini_FloatSet(path, "Y", 1343.1572);
        dini_FloatSet(path, "Z", 15.3746);
        dini_IntSet(path, "Interior", 0);
        dini_IntSet(path, "VW", 0);
        dini_IntSet(path, "Skin", 26);

        Logado[playerid] = true;
        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);
        return 1;
    }

    if(dialogid == DIALOG_LOGIN)
    {
        new senha[32];
        dini_Get(path, "Senha", senha);

        if(!strcmp(inputtext, senha, false))
        {
            Logado[playerid] = true;
            TogglePlayerControllable(playerid, true);

            SetPlayerPos(playerid,
                dini_Float(path, "X"),
                dini_Float(path, "Y"),
                dini_Float(path, "Z"));

            SetPlayerInterior(playerid, dini_Int(path, "Interior"));
            SetPlayerVirtualWorld(playerid, dini_Int(path, "VW"));
            SetPlayerSkin(playerid, dini_Int(path, "Skin"));

            ResetPlayerMoney(playerid);
            GivePlayerMoney(playerid, dini_Int(path, "Dinheiro"));

            SpawnPlayer(playerid);
        }
        else
        {
            SendClientMessage(playerid, -1, "Senha incorreta!");
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
                "Login", "Digite sua senha:", "Entrar", "Sair");
        }
        return 1;
    }
    return 0;
}

// ================= SAVE =================
public OnPlayerDisconnect(playerid, reason)
{
    if(!Logado[playerid]) return 1;

    new path[64], Float:x, Float:y, Float:z;
    ContaPath(playerid, path, sizeof path);

    GetPlayerPos(playerid, x, y, z);

    dini_IntSet(path, "Dinheiro", GetPlayerMoney(playerid));
    dini_FloatSet(path, "X", x);
    dini_FloatSet(path, "Y", y);
    dini_FloatSet(path, "Z", z);
    dini_IntSet(path, "Interior", GetPlayerInterior(playerid));
    dini_IntSet(path, "VW", GetPlayerVirtualWorld(playerid));
    dini_IntSet(path, "Skin", GetPlayerSkin(playerid));
    return 1;
}

// ================= INIT =================
public OnGameModeInit()
{
    SetGameModeText("Cidade RP Full");
    return 1;
}
