#include <a_samp>
#include <dini>

#define DIALOG_LOGIN    1
#define DIALOG_REGISTER 2

new bool:Logado[MAX_PLAYERS];

// =======================
// FUNÇÃO DE CAMINHO
// =======================
stock ContaPath(playerid, path[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof nome);
    format(path, size, "Contas/%s.ini", nome);
}

// =======================
// PLAYER CONNECT
// =======================
public OnPlayerConnect(playerid)
{
    new path[64];
    ContaPath(playerid, path, sizeof path);

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
            "Crie uma senha:",
            "Registrar", "Sair");
    }
    return 1;
}

// =======================
// DIALOG RESPONSE
// =======================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (!response)
    {
        Kick(playerid);
        return 1;
    }

    new path[64];
    ContaPath(playerid, path, sizeof path);

    if (dialogid == DIALOG_REGISTER)
    {
        if (strlen(inputtext) < 3)
        {
            ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
                "Registro",
                "Senha muito curta.\nDigite outra:",
                "Registrar", "Sair");
            return 1;
        }

        dini_Create(path);
        dini_Set(path, "Senha", inputtext);
        dini_IntSet(path, "Dinheiro", 500);
        dini_IntSet(path, "Admin", 0);

        Logado[playerid] = true;
        GivePlayerMoney(playerid, 500);

        SendClientMessage(playerid, -1, "Conta criada com sucesso!");
        SpawnPlayer(playerid);
        return 1;
    }

    if (dialogid == DIALOG_LOGIN)
    {
        new senhaSalva[32];
        dini_Get(path, "Senha", senhaSalva);

        if (!strcmp(inputtext, senhaSalva, false))
        {
            Logado[playerid] = true;

            new money = dini_Int(path, "Dinheiro");
            ResetPlayerMoney(playerid);
            GivePlayerMoney(playerid, money);

            SendClientMessage(playerid, -1, "Login efetuado com sucesso!");
            SpawnPlayer(playerid);
        }
        else
        {
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
                "Login",
                "Senha incorreta.\nDigite novamente:",
                "Entrar", "Sair");
        }
        return 1;
    }
    return 0;
}

// =======================
// BLOQUEAR SPAWN SEM LOGIN
// =======================
public OnPlayerRequestSpawn(playerid)
{
    if (!Logado[playerid])
    {
        SendClientMessage(playerid, -1, "Você precisa logar primeiro!");
        return 0;
    }
    return 1;
}

// =======================
// SALVAR AO SAIR
// =======================
public OnPlayerDisconnect(playerid, reason)
{
    if (Logado[playerid])
    {
        new path[64];
        ContaPath(playerid, path, sizeof path);
        dini_IntSet(path, "Dinheiro", GetPlayerMoney(playerid));
    }
    return 1;
}

// =======================
// GAMEMODE INIT
// =======================
public OnGameModeInit()
{
    print("Gamemode iniciado!");
    SetGameModeText("Cidade RP Full");
    return 1;
}
