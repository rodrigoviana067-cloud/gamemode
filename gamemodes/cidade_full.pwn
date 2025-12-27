#include <a_samp>
#include <dini>
#include <zcmd>
#include <sscanf2>

// ================= DIALOGS =================
#define DIALOG_LOGIN    1
#define DIALOG_REGISTER 2
#define DIALOG_MENU     100
#define DIALOG_GPS      2001

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

// ================= GPS =================
new PlayerGPS[MAX_PLAYERS]; // Blip atual do jogador

// ================= SPAWN PADRÃO =================
#define SPAWN_X 1702.5
#define SPAWN_Y 328.5
#define SPAWN_Z 10.0
#define SPAWN_INT 0
#define SPAWN_VW 0
#define SPAWN_SKIN 26  // Skin masculina padrão RP

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
        SendClientMessage(playerid, 0xFF0000FF, "Você não tem permissão para este comando.");
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
    PlayerGPS[playerid] = INVALID_PLAYER_ID;

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

    // Registro
    if(dialogid == DIALOG_REGISTER)
    {
        dini_Create(path);
        dini_Set(path, "Senha", inputtext);
        dini_IntSet(path, "Dinheiro", 500);
        dini_IntSet(path, "Admin", 0);
        dini_IntSet(path, "Celular", 1);
        dini_IntSet(path, "Emprego", 0);

        // Spawn inicial
        SpawnX[playerid] = SPAWN_X;
        SpawnY[playerid] = SPAWN_Y;
        SpawnZ[playerid] = SPAWN_Z;
        SpawnInt[playerid] = SPAWN_INT;
        SpawnVW[playerid] = SPAWN_VW;
        SpawnSkin[playerid] = SPAWN_SKIN;

        Logado[playerid] = true;
        TemCelular[playerid] = 1;
        PlayerAdmin[playerid] = 0;

        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);
        return 1;
    }

    // Login
    if(dialogid == DIALOG_LOGIN)
    {
        new senha[32];
        dini_Get(path, "Senha", senha);

        if(strcmp(inputtext, senha, false))
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

        // Carregar spawn salvo
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

    // Menu principal
    if(dialogid == DIALOG_MENU)
    {
        if(listitem == 0)
        {
            SendClientMessage(playerid, 0xFFFF00FF, "Lista de empregos disponíveis:");
            SendClientMessage(playerid, 0xFFFF00FF, "/policial /medico /trabalhador /taxista");
        }
        else if(listitem == 1)
        {
            // GPS Menu
            ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST,
                "GPS - Locais", "Aeroporto LS\nDowntown LS\nHospital\nPrefeitura", "Ir", "Fechar");
        }
        else if(listitem == 2)
        {
            SendClientMessage(playerid, 0xFFFF00FF, "Propriedades e casas disponíveis:");
            SendClientMessage(playerid, 0xFFFF00FF, "Compre casas com /comprarcasa");
        }
        return 1;
    }

    // GPS Selection
    if(dialogid == DIALOG_GPS)
    {
        new Float:x, y, z;
        if(listitem == 0) { x = 1702.5; y = 328.5; z = 10.0; }
        else if(listitem == 1) { x = 500.0; y = -1000.0; z = 20.0; }
        else if(listitem == 2) { x = 2000.0; y = 1000.0; z = 15.0; }
        else if(listitem == 3) { x = 2500.0; y = 1500.0; z = 15.0; }
        else return 1;

        // Marca o GPS no mapa
        if(PlayerGPS[playerid] != INVALID_PLAYER_ID)
            RemovePlayerBlip(playerid, PlayerGPS[playerid]);

        PlayerGPS[playerid] = CreateDynamicBlip(x, y, z, 0, 0, playerid);
        SendClientMessage(playerid, 0x00FF00FF, "GPS atualizado! Confira o ponto no mapa.");
        return 1;
    }

    return 0;
}

// ================= SPAWN =================
public OnPlayerSpawn(playerid)
{
    if(SpawnX[playerid] == 0.0 && SpawnY[playerid] == 0.0)
    {
        SpawnX[playerid] = SPAWN_X;
        SpawnY[playerid] = SPAWN_Y;
        SpawnZ[playerid] = SPAWN_Z;
        SpawnInt[playerid] = SPAWN_INT;
        SpawnVW[playerid] = SPAWN_VW;
        SpawnSkin[playerid] = SPAWN_SKIN;
    }

    SetPlayerPos(playerid, SpawnX[playerid], SpawnY[playerid], SpawnZ[playerid]);
    SetPlayerInterior(playerid, SpawnInt[playerid]);
    SetPlayerVirtualWorld(playerid, SpawnVW[playerid]);
    SetPlayerSkin(playerid, SpawnSkin[playerid]);

    SendClientMessage(playerid, 0x00FF00FF, "Bem-vindo à Cidade RP Full!");
    return 1;
}

// ================= COMANDOS =================
CMD:dis(playerid, params[])
{
    if(!Logado[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Você precisa estar logado.");
    if(!TemCelular[playerid]) return SendClientMessage(playerid, 0xFF0000FF, "Você não possui celular.");
    if(isnull(params)) return SendClientMessage(playerid, 0xFFFF00FF, "Uso correto: /dis [mensagem]");

    new nome[MAX_PLAYER_NAME], msg[144];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(msg, sizeof(msg), "[DISPATCH] %s: %s", nome, params);

    for(new i=0; i<MAX_PLAYERS; i++)
        if(IsPlayerConnected(i) && TemCelular[i])
            SendClientMessage(i, 0x00FF00FF, msg);

    return 1;
}

CMD:menu(playerid, params[])
{
    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,
        "Menu Cidade RP Full", 
        "Empregos\nGPS\nCasas", "Selecionar", "Fechar");
    return 1;
}

CMD:ajuda(playerid, params[])
{
    SendClientMessage(playerid, -1, "Comandos: /dis /ajuda /admins /setadmin /setmoney /ir /dinheiro /menu /comprarcasa /policial /medico /trabalhador /taxista");
    return 1;
}

CMD:admins(playerid, params[])
{
    new texto[512], nome[MAX_PLAYER_NAME], c=0;
    format(texto, sizeof(texto), "Admins online:\n");

    for(new i=0; i<MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && PlayerAdmin[i] > 0)
        {
            GetPlayerName(i, nome, sizeof(nome));
            format(texto, sizeof(texto), "%s%s (Nivel %d)\n", texto, nome, PlayerAdmin[i]);
            c++;
        }
    }

    if(!c) return SendClientMessage(playerid, -1, "Nenhum admin online.");

    ShowPlayerDialog(playerid, 2000, DIALOG_STYLE_MSGBOX, "Admins", texto, "OK", "");
    return 1;
}

CMD:setadmin(playerid, params[])
{
    if(!IsAdmin(playerid, 5)) return 1;

    new id, nivel;
    if(sscanf(params, "dd", id, nivel)) return SendClientMessage(playerid, -1, "Uso correto: /setadmin [id] [nivel]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, -1, "Jogador inválido.");

    PlayerAdmin[id] = nivel;

    new path[64];
    ContaPath(id, path, sizeof(path));
    dini_IntSet(path, "Admin", nivel);

    SendClientMessage(playerid, -1, "Admin definido com sucesso.");
    return 1;
}

CMD:setmoney(playerid, params[])
{
    if(!IsAdmin(playerid, 4)) return 1;

    new id, valor;
    if(sscanf(params, "dd", id, valor)) return SendClientMessage(playerid, -1, "Uso correto: /setmoney [id] [valor]");

    ResetPlayerMoney(id);
    GivePlayerMoney(id, valor);
    return 1;
}

CMD:ir(playerid, params[])
{
    if(!IsAdmin(playerid, 3)) return 1;

    new id;
    if(sscanf(params, "d", id)) return SendClientMessage(playerid, -1, "Uso correto: /ir [id]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, -1, "Jogador inválido.");

    new Float:x, y, z;
    GetPlayerPos(id, x, y, z);
    SetPlayerPos(playerid, x+1.0, y, z);
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

// ================= ANTI UNKNOWN COMMAND =================
public OnPlayerCommandText(playerid, cmdtext[])
{
    SendClientMessage(playerid, 0xFF0000FF, "ERRO: Comando inexistente. Use /ajuda.");
    return 1;
}

// ================= FUNÇÃO AUXILIAR =================
stock CreateDynamicBlip(Float:x, Float:y, Float:z, type, color, playerid)
{
    return CreatePlayer3DTextLabel("GPS", x, y, z+1.0, 0xFF0000FF, playerid, 999.0, 0); // Blip simulado com 3D text
}
