#include <a_samp>
#include <dini>
#include <zcmd>
#include <sscanf2>

// ================= DIALOGS =================
#define DIALOG_LOGIN    1
#define DIALOG_REGISTER 2
#define DIALOG_MENU     100
#define DIALOG_GPS      200

// ================= VARIÁVEIS =================
new bool:Logado[MAX_PLAYERS];
new TemCelular[MAX_PLAYERS];
new PlayerAdmin[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];
new bool:GPSAtivo[MAX_PLAYERS];

// ================= SPAWN PADRÃO =================
#define SPAWN_X 1702.5
#define SPAWN_Y 328.5
#define SPAWN_Z 10.0
#define SPAWN_INT 0
#define SPAWN_VW 0
#define SPAWN_SKIN 26

// ================= MAIN =================
main()
{
    print("Cidade RP Full carregada com sucesso.");
    return 1;
}

// ================= PATH =================
stock ContaPath(playerid, path[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(path, size, "Contas/%s.ini", nome);
}

// ================= CONNECT =================
public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    GPSAtivo[playerid] = false;
    TogglePlayerControllable(playerid, false);

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    if(dini_Exists(path))
    {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
            "Login", "Digite sua senha:", "Entrar", "Sair");
    }
    else
    {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
            "Registro", "Crie sua senha:", "Registrar", "Sair");
    }
    return 1;
}

// ================= DIALOG =================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(!response) return Kick(playerid);

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    // ===== REGISTRO =====
    if(dialogid == DIALOG_REGISTER)
    {
        if(strlen(inputtext) < 3)
        {
            ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
                "Registro", "Senha muito curta!", "Registrar", "Sair");
            return 1;
        }

        dini_Create(path);
        dini_Set(path, "Senha", inputtext);
        dini_IntSet(path, "Dinheiro", 500);
        dini_IntSet(path, "Admin", 0);
        dini_IntSet(path, "Emprego", 0);

        dini_FloatSet(path, "X", SPAWN_X);
        dini_FloatSet(path, "Y", SPAWN_Y);
        dini_FloatSet(path, "Z", SPAWN_Z);
        dini_IntSet(path, "Interior", SPAWN_INT);
        dini_IntSet(path, "VW", SPAWN_VW);
        dini_IntSet(path, "Skin", SPAWN_SKIN);

        Logado[playerid] = true;
        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);
        return 1;
    }

    // ===== LOGIN =====
    if(dialogid == DIALOG_LOGIN)
    {
        new senha[32];
        dini_Get(path, "Senha", senha);

        if(strcmp(inputtext, senha, false) != 0)
        {
            SendClientMessage(playerid, 0xFF0000FF, "Senha incorreta!");
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
                "Login", "Digite sua senha:", "Entrar", "Sair");
            return 1;
        }

        Logado[playerid] = true;

        ResetPlayerMoney(playerid);
        GivePlayerMoney(playerid, dini_Int(path, "Dinheiro"));

        SetPlayerInterior(playerid, dini_Int(path, "Interior"));
        SetPlayerVirtualWorld(playerid, dini_Int(path, "VW"));
        SetPlayerSkin(playerid, dini_Int(path, "Skin"));
        SetPlayerPos(playerid,
            dini_Float(path, "X"),
            dini_Float(path, "Y"),
            dini_Float(path, "Z"));

        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);
        return 1;
    }

    // ===== GPS =====
    if(dialogid == DIALOG_GPS)
    {
        DisablePlayerCheckpoint(playerid);

        if(listitem == 0) SetPlayerCheckpoint(playerid, 1555.0, -1675.0, 16.2, 5.0); // Prefeitura LS
        if(listitem == 1) SetPlayerCheckpoint(playerid, 1172.0, -1323.0, 15.4, 5.0); // Hospital
        if(listitem == 2) SetPlayerCheckpoint(playerid, 2102.0, -1786.0, 13.5, 5.0); // Concessionária

        GPSAtivo[playerid] = true;
        SendClientMessage(playerid, 0x00FF00FF, "GPS marcado no mapa (ponto vermelho).");
        return 1;
    }

    return 1;
}

// ================= SPAWN =================
public OnPlayerSpawn(playerid)
{
    SendClientMessage(playerid, 0x00FF00FF, "Bem-vindo à Cidade RP Full!");
    return 1;
}

// ================= COMANDOS =================
CMD:gps(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST,
        "GPS", "Prefeitura LS\nHospital\nConcessionária", "Marcar", "Cancelar");
    return 1;
}

CMD:cancelargps(playerid)
{
    DisablePlayerCheckpoint(playerid);
    GPSAtivo[playerid] = false;
    SendClientMessage(playerid, 0xFF0000FF, "GPS cancelado.");
    return 1;
}

// ================= SAVE =================
public OnPlayerDisconnect(playerid, reason)
{
    if(!Logado[playerid]) return 1;

    new path[64], Float:x, y, z;
    ContaPath(playerid, path, sizeof(path));
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
