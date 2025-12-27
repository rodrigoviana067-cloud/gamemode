#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <dini>

// ================== DEFINES ==================
#define COR_VERMELHO 0xFF0000FF
#define COR_VERDE    0x00FF00FF
#define COR_AMARELO  0xFFFF00FF
#define COR_BRANCO   0xFFFFFFFF

#define DIALOG_LOGIN     1
#define DIALOG_REGISTER  2

// Spawn LS (Aeroporto)
#define SPAWN_X 1687.47
#define SPAWN_Y -2334.78
#define SPAWN_Z 13.55

// ================== VARIÁVEIS ==================
new bool:Logado[MAX_PLAYERS];
new TemCelular[MAX_PLAYERS];
new PlayerAdmin[MAX_PLAYERS];

new Float:SpawnX[MAX_PLAYERS];
new Float:SpawnY[MAX_PLAYERS];
new Float:SpawnZ[MAX_PLAYERS];
new SpawnInt[MAX_PLAYERS];
new SpawnVW[MAX_PLAYERS];
new SpawnSkin[MAX_PLAYERS];

// ================== MAIN ==================
main()
{
    print("Cidade RP Full carregada com sucesso.");
}

// ================== PATH ==================
stock ContaPath(playerid, path[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof nome);
    format(path, size, "Contas/%s.ini", nome);
}

// ================== ADMIN CHECK ==================
stock IsAdmin(playerid, nivel)
{
    if(PlayerAdmin[playerid] < nivel)
    {
        SendClientMessage(playerid, COR_VERMELHO,
            "[ERRO] Você não tem permissão.");
        return 0;
    }
    return 1;
}

// ================== CONNECT ==================
public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    TemCelular[playerid] = 0;
    PlayerAdmin[playerid] = 0;

    TogglePlayerControllable(playerid, false);
    ResetPlayerMoney(playerid);

    new path[64];
    ContaPath(playerid, path, sizeof path);

    if(dini_Exists(path))
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
            "Login", "Digite sua senha:", "Entrar", "Sair");
    else
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
            "Registro", "Crie sua senha:", "Registrar", "Sair");

    return 1;
}

// ================== REQUEST CLASS ==================
public OnPlayerRequestClass(playerid, classid)
{
    SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
    SetPlayerFacingAngle(playerid, 0.0);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerSkin(playerid, 26); // Skin RP padrão
    return 1;
}

// ================== DIALOG ==================
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

        dini_FloatSet(path, "X", SPAWN_X);
        dini_FloatSet(path, "Y", SPAWN_Y);
        dini_FloatSet(path, "Z", SPAWN_Z);
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

        if(strcmp(inputtext, senha, false))
        {
            SendClientMessage(playerid, COR_VERMELHO, "Senha incorreta.");
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
                "Login", "Digite sua senha:", "Entrar", "Sair");
            return 1;
        }

        Logado[playerid] = true;
        TemCelular[playerid] = dini_Int(path, "Celular");
        PlayerAdmin[playerid] = dini_Int(path, "Admin");

        SpawnX[playerid] = dini_Float(path, "X");
        SpawnY[playerid] = dini_Float(path, "Y");
        SpawnZ[playerid] = dini_Float(path, "Z");
        SpawnInt[playerid] = dini_Int(path, "Interior");
        SpawnVW[playerid] = dini_Int(path, "VW");
        SpawnSkin[playerid] = dini_Int(path, "Skin");

        ResetPlayerMoney(playerid);
        GivePlayerMoney(playerid, dini_Int(path, "Dinheiro"));

        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);
        return 1;
    }
    return 1;
}

// ================== SPAWN ==================
public OnPlayerSpawn(playerid)
{
    if(!Logado[playerid]) return 0;

    SetPlayerInterior(playerid, SpawnInt[playerid]);
    SetPlayerVirtualWorld(playerid, SpawnVW[playerid]);
    SetPlayerPos(playerid, SpawnX[playerid], SpawnY[playerid], SpawnZ[playerid]);
    SetPlayerSkin(playerid, SpawnSkin[playerid]);
    return 1;
}

// ================== DIS ==================
CMD:dis(playerid, params[])
{
    if(!Logado[playerid])
        return SendClientMessage(playerid, COR_VERMELHO, "Você não está logado.");

    if(!TemCelular[playerid])
        return SendClientMessage(playerid, COR_VERMELHO, "Você não tem celular.");

    if(isnull(params))
        return SendClientMessage(playerid, COR_AMARELO, "Uso: /dis [mensagem]");

    new nome[MAX_PLAYER_NAME], msg[144];
    GetPlayerName(playerid, nome, sizeof nome);
    format(msg, sizeof msg, "[DISPATCH] %s: %s", nome, params);

    for(new i; i < MAX_PLAYERS; i++)
        if(IsPlayerConnected(i) && TemCelular[i])
            SendClientMessage(i, COR_VERDE, msg);

    return 1;
}

// ================== ADMINS ==================
CMD:admins(playerid, params[])
{
    new texto[256], nome[MAX_PLAYER_NAME], c;
    strcat(texto, "Admins Online:\n");

    for(new i; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && PlayerAdmin[i] > 0)
        {
            GetPlayerName(i, nome, sizeof nome);
            format(texto, sizeof texto, "%s%s (Nível %d)\n",
                texto, nome, PlayerAdmin[i]);
            c++;
        }
    }

    if(!c) return SendClientMessage(playerid, COR_AMARELO, "Nenhum admin online.");

    ShowPlayerDialog(playerid, 2000, DIALOG_STYLE_MSGBOX,
        "Admins", texto, "OK", "");
    return 1;
}

// ================== SETADMIN ==================
CMD:setadmin(playerid, params[])
{
    if(!IsAdmin(playerid, 5)) return 1;

    new id, nivel;
    if(sscanf(params, "dd", id, nivel))
        return SendClientMessage(playerid, COR_AMARELO, "/setadmin [id] [nivel]");

    PlayerAdmin[id] = nivel;

    new path[64];
    ContaPath(id, path, sizeof path);
    dini_IntSet(path, "Admin", nivel);

    SendClientMessage(playerid, COR_VERDE, "Admin definido com sucesso.");
    return 1;
}

// ================== SAVE ==================
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

// ================== INIT ==================
public OnGameModeInit()
{
    SetGameModeText("Cidade RP Full");
    return 1;
}

// ================== ANTI UNKNOWN ==================
public OnPlayerCommandText(playerid, cmdtext[])
{
    SendClientMessage(playerid, COR_VERMELHO,
        "[ERRO] Comando inexistente. Use /ajuda.");
    return 1;
}
