#include <a_samp>
#include <dini>
#include <zcmd>
#include <sscanf2>

// ================= DIALOGS =================
#define DIALOG_LOGIN    1
#define DIALOG_REGISTER 2

// ================= VARIÁVEIS =================
new bool:Logado[MAX_PLAYERS];
new TemCelular[MAX_PLAYERS];
new PlayerAdmin[MAX_PLAYERS];

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

// ================= ADMIN CHECK =================
stock IsAdmin(playerid, level)
{
    if(PlayerAdmin[playerid] < level)
    {
        SendClientMessage(playerid, 0xFF0000FF,
            "Você não tem permissão para usar este comando.");
        return 0;
    }
    return 1;
}

// ================= CONNECT =================
public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    TemCelular[playerid] = 0;
    PlayerAdmin[playerid] = 0;

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
        dini_IntSet(path, "Celular", 1);

        dini_FloatSet(path, "X", 1958.3783);
        dini_FloatSet(path, "Y", 1343.1572);
        dini_FloatSet(path, "Z", 15.3746);
        dini_IntSet(path, "Interior", 0);
        dini_IntSet(path, "VW", 0);
        dini_IntSet(path, "Skin", 26);

        Logado[playerid] = true;
        TemCelular[playerid] = 1;
        PlayerAdmin[playerid] = 0;

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
            PlayerAdmin[playerid] = dini_Int(path, "Admin");

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

// ================= /DIS =================
CMD:dis(playerid, params[])
{
    if(!Logado[playerid])
        return SendClientMessage(playerid, 0xFF0000FF, "Você precisa estar logado.");

    if(!TemCelular[playerid])
        return SendClientMessage(playerid, 0xFF0000FF, "Você não possui um celular.");

    if(isnull(params))
        return SendClientMessage(playerid, 0xFFFF00FF, "Uso correto: /dis [mensagem]");

    new nome[MAX_PLAYER_NAME], msg[144];
    GetPlayerName(playerid, nome, sizeof nome);
    format(msg, sizeof msg, "[DISPATCH] %s: %s", nome, params);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && TemCelular[i])
            SendClientMessage(i, 0x00FF00FF, msg);
    }
    return 1;
}

// ================= ADMINS =================
CMD:admins(playerid, params[])
{
    new texto[256], nome[MAX_PLAYER_NAME], count;
    strcat(texto, "Admins online:\n");

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && PlayerAdmin[i] > 0)
        {
            GetPlayerName(i, nome, sizeof nome);
            format(texto, sizeof texto, "%s%s (Nivel %d)\n",
                texto, nome, PlayerAdmin[i]);
            count++;
        }
    }

    if(!count)
        return SendClientMessage(playerid, -1, "Nenhum admin online.");

    ShowPlayerDialog(playerid, 2000, DIALOG_STYLE_MSGBOX,
        "Admins", texto, "OK", "");
    return 1;
}

CMD:setadmin(playerid, params[])
{
    if(!IsAdmin(playerid, 5)) return 1;

    new id, nivel;
    if(sscanf(params, "dd", id, nivel))
        return SendClientMessage(playerid, -1, "/setadmin [id] [nivel]");

    if(!IsPlayerConnected(id))
        return SendClientMessage(playerid, -1, "Jogador inválido.");

    PlayerAdmin[id] = nivel;

    new path[64];
    ContaPath(id, path, sizeof path);
    dini_IntSet(path, "Admin", nivel);

    SendClientMessage(playerid, -1, "Admin definido com sucesso.");
    return 1;
}

CMD:setmoney(playerid, params[])
{
    if(!IsAdmin(playerid, 4)) return 1;

    new id, valor;
    if(sscanf(params, "dd", id, valor))
        return SendClientMessage(playerid, -1, "/setmoney [id] [valor]");

    ResetPlayerMoney(id);
    GivePlayerMoney(id, valor);
    return 1;
}

CMD:ir(playerid, params[])
{
    if(!IsAdmin(playerid, 3)) return 1;

    new id;
    if(sscanf(params, "d", id))
        return SendClientMessage(playerid, -1, "/ir [id]");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(id, x, y, z);
    SetPlayerPos(playerid, x + 1.0, y, z);
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
    dini_IntSet(path, "Admin", PlayerAdmin[playerid]);

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

// ================= ANTI UNKNOWN COMMAND =================
public OnPlayerCommandText(playerid, cmdtext[])
{
    SendClientMessage(playerid, 0xAAAAAAFF,
        "Comando inválido. Use /ajuda.");
    return 1;
}
