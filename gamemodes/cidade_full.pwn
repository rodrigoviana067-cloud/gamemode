#include <a_samp>
#include <dini>
#include <zcmd>
#include <sscanf2>

// ================= DIALOGS =================
#define DIALOG_LOGIN    1
#define DIALOG_REGISTER 2
#define DIALOG_MENU     100

// ================= VARIÁVEIS =================
new bool:Logado[MAX_PLAYERS];
new TemCelular[MAX_PLAYERS];
new PlayerAdmin[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];

new Float:SpawnX[MAX_PLAYERS];
new Float:SpawnY[MAX_PLAYERS];
new Float:SpawnZ[MAX_PLAYERS];
new SpawnInt[MAX_PLAYERS];
new SpawnVW[MAX_PLAYERS];
new SpawnSkin[MAX_PLAYERS];

// ================= SPAWN PADRÃO (LS) =================
#define SPAWN_X 1702.5
#define SPAWN_Y 328.5
#define SPAWN_Z 10.0
#define SPAWN_INT 0
#define SPAWN_VW 0
#define SPAWN_SKIN 26

// ================= MAIN =================
main()
{
    print("Gamemode Cidade RP Full carregado.");
    return 1;
}

// ================= PATH =================
stock ContaPath(playerid, path[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(path, size, "Contas/%s.ini", nome);
}

// ================= ADMIN CHECK =================
stock IsAdmin(playerid, level)
{
    if (PlayerAdmin[playerid] < level)
    {
        SendClientMessage(playerid, 0xFF0000FF, "Você não tem permissão.");
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
    PlayerEmprego[playerid] = 0;

    TogglePlayerControllable(playerid, false);
    ResetPlayerMoney(playerid);

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    if (dini_Exists(path))
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

// ================= DIALOG RESPONSE =================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (!response) return Kick(playerid);

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    // ================= REGISTRO =================
    if(dialogid == DIALOG_REGISTER)
    {
        dini_Create(path);
        dini_Set(path, "Senha", inputtext);
        dini_IntSet(path, "Dinheiro", 500);
        dini_IntSet(path, "Admin", 0);
        dini_IntSet(path, "Celular", 1);
        dini_IntSet(path, "Emprego", 0);

        // SALVAR SPAWN PADRÃO (ANTI-CRASH)
        dini_FloatSet(path, "X", SPAWN_X);
        dini_FloatSet(path, "Y", SPAWN_Y);
        dini_FloatSet(path, "Z", SPAWN_Z);
        dini_IntSet(path, "Interior", SPAWN_INT);
        dini_IntSet(path, "VW", SPAWN_VW);
        dini_IntSet(path, "Skin", SPAWN_SKIN);

        Logado[playerid] = true;
        TemCelular[playerid] = 1;

        SpawnX[playerid] = SPAWN_X;
        SpawnY[playerid] = SPAWN_Y;
        SpawnZ[playerid] = SPAWN_Z;
        SpawnInt[playerid] = SPAWN_INT;
        SpawnVW[playerid] = SPAWN_VW;
        SpawnSkin[playerid] = SPAWN_SKIN;

        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);
        return 1;
    }

    // ================= LOGIN =================
    if(dialogid == DIALOG_LOGIN)
    {
        new senha[32];
        dini_Get(path, "Senha", senha);

        // CORREÇÃO DO strcmp
        if(strcmp(inputtext, senha, false) != 0)
        {
            SendClientMessage(playerid, 0xFF0000FF, "Senha incorreta!");
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
                "Login", "Digite sua senha:", "Entrar", "Sair");
            return 1;
        }

        Logado[playerid] = true;
        TemCelular[playerid] = dini_Int(path, "Celular");
        PlayerAdmin[playerid] = dini_Int(path, "Admin");
        PlayerEmprego[playerid] = dini_Int(path, "Emprego");

        SpawnX[playerid] = dini_Float(path, "X");
        SpawnY[playerid] = dini_Float(path, "Y");
        SpawnZ[playerid] = dini_Float(path, "Z");

        // ANTI X=0 Y=0
        if(SpawnX[playerid] == 0.0 && SpawnY[playerid] == 0.0)
        {
            SpawnX[playerid] = SPAWN_X;
            SpawnY[playerid] = SPAWN_Y;
            SpawnZ[playerid] = SPAWN_Z;
        }

        SpawnInt[playerid] = dini_Int(path, "Interior");
        SpawnVW[playerid] = dini_Int(path, "VW");
        SpawnSkin[playerid] = dini_Int(path, "Skin");

        ResetPlayerMoney(playerid);
        GivePlayerMoney(playerid, dini_Int(path, "Dinheiro"));

        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);
        return 1;
    }

    // ================= MENU =================
    if(dialogid == DIALOG_MENU)
    {
        if(listitem == 0)
            SendClientMessage(playerid, -1, "Empregos: /policia /medico /taxi /mecanico");
        else if(listitem == 1)
            SendClientMessage(playerid, -1, "GPS informativo (sem teleport).");
        else if(listitem == 2)
            SendClientMessage(playerid, -1, "Casas disponíveis em breve.");
        return 1;
    }

    return 0;
}

// ================= SPAWN =================
public OnPlayerSpawn(playerid)
{
    SendClientMessage(playerid, 0x00FF00FF, "Bem-vindo à Cidade RP Full!");
    return 1;
}

// ================= COMANDOS =================
CMD:menu(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,
        "Menu Cidade RP", "Empregos\nGPS\nCasas", "Selecionar", "Fechar");
    return 1;
}

CMD:dinheiro(playerid)
{
    new msg[64];
    format(msg, sizeof(msg), "Seu dinheiro: $%d", GetPlayerMoney(playerid));
    SendClientMessage(playerid, -1, msg);
    return 1;
}

// ================= SAVE =================
public OnPlayerDisconnect(playerid, reason)
{
    if(!Logado[playerid]) return 1;

    new path[64];
    new Float:x, y, z;
    ContaPath(playerid, path, sizeof(path));

    GetPlayerPos(playerid, x, y, z);

    dini_IntSet(path, "Dinheiro", GetPlayerMoney(playerid));
    dini_IntSet(path, "Celular", TemCelular[playerid]);
    dini_IntSet(path, "Admin", PlayerAdmin[playerid]);
    dini_IntSet(path, "Emprego", PlayerEmprego[playerid]);

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
