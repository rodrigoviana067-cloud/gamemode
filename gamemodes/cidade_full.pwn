#include <a_samp>
#include <dini>
#include <zcmd>

#define DIALOG_LOGIN    1
#define DIALOG_REGISTER 2

new bool:Logado[MAX_PLAYERS];
new TemCelular[MAX_PLAYERS];

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
    TemCelular[playerid] = 0;

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
        dini_IntSet(path, "Celular", 1); // começa com celular

        dini_FloatSet(path, "X", 1958.3783);
        dini_FloatSet(path, "Y", 1343.1572);
        dini_FloatSet(path, "Z", 15.3746);
        dini_IntSet(path, "Interior", 0);
        dini_IntSet(path, "VW", 0);
        dini_IntSet(path, "Skin", 26);

        Logado[playerid] = true;
        TemCelular[playerid] = 1;

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
            TemCelular[playerid] = dini_Int(path, "Celular");

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
            SendClientMessage(playerid, 0xFF0000FF, "Senha incorreta!");
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
                "Login", "Digite sua senha:", "Entrar", "Sair");
        }
        return 1;
    }
    return 0;
}

// ================= COMANDO /DIS =================
CMD:dis(playerid, params[])
{
    if(!Logado[playerid])
        return SendClientMessage(playerid, 0xFF0000FF, "Você precisa estar logado.");

    if(!TemCelular[playerid])
        return SendClientMessage(playerid, 0xFF0000FF, "Você não possui um celular.");

    if(isnull(params))
        return SendClientMessage(playerid, 0xFFFF00FF, "Uso correto: /dis [mensagem]");

    new nome[MAX_PLAYER_NAME];
    new msg[144];
    GetPlayerName(playerid, nome, sizeof nome);

    format(msg, sizeof msg, "[DISPATCH] %s: %s", nome, params);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && TemCelular[i])
        {
            SendClientMessage(i, 0x00FF00FF, msg);
        }
    }
    return 1;
}

// ================= SAVE =================
public OnPlayerDisconnect(playerid, reason)
{
    if(!Logado[playerid]) return 1;

    new path[64], Float:x, Float:y, Float:z;
    ContaPath(playerid, path, sizeof path);

    GetPlayerPos(playerid, x, y, z);

    dini_IntSet(path, "Dinheiro", GetPlayerMoney(playerid));
    dini_IntSet(path, "Celular", TemCelular[playerid]);

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
