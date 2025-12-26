#include <a_samp>
#include <dini>

#define DIALOG_LOGIN    1
#define DIALOG_REGISTER 2

new bool:Logado[MAX_PLAYERS];
new SenhaTentativa[MAX_PLAYERS][32];

stock ContaPath(playerid)
{
    new nome[MAX_PLAYER_NAME], path[64];
    GetPlayerName(playerid, nome, sizeof nome);
    format(path, sizeof path, "Contas/%s.ini", nome);
    return path;
}

public OnGameModeInit()
{
    SetGameModeText("Cidade RP");
    return 1;
}

public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;

    if (dini_Exists(ContaPath(playerid)))
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

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (!response)
    {
        Kick(playerid);
        return 1;
    }

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

        dini_Create(ContaPath(playerid));
        dini_Set(ContaPath(playerid), "Senha", inputtext);
        dini_IntSet(ContaPath(playerid), "Dinheiro", 500);
        dini_IntSet(ContaPath(playerid), "Admin", 0);

        Logado[playerid] = true;
        GivePlayerMoney(playerid, 500);

        SendClientMessage(playerid, -1, "Conta criada com sucesso!");
        SpawnPlayer(playerid);
        return 1;
    }

    if (dialogid == DIALOG_LOGIN)
    {
        new senhaSalva[32];
        dini_Get(ContaPath(playerid), "Senha", senhaSalva);

        if (!strcmp(inputtext, senhaSalva, false))
        {
            Logado[playerid] = true;

            new money = dini_Int(ContaPath(playerid), "Dinheiro");
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

public OnPlayerRequestSpawn(playerid)
{
    if (!Logado[playerid])
    {
        SendClientMessage(playerid, -1, "Você precisa logar primeiro!");
        return 0;
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if (Logado[playerid])
    {
        dini_IntSet(ContaPath(playerid), "Dinheiro", GetPlayerMoney(playerid));
    }
    return 1;
}

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
