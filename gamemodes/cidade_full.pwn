#include <a_samp>
#include <zcmd>
#include <dini>

// ================= DIALOGS =================
#define DIALOG_LOGIN        1
#define DIALOG_REGISTER     2
#define DIALOG_MENU         10
#define DIALOG_PREFEITURA   20
#define DIALOG_EMPREGOS     21
#define DIALOG_GPS          30

// ================= EMPREGOS =================
#define EMPREGO_NENHUM   0
#define EMPREGO_POLICIA  1
#define EMPREGO_SAMU     2
#define EMPREGO_TAXI     3
#define EMPREGO_MEC      4

// ================= VARIÁVEIS =================
new bool:Logado[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];

// ================= SPAWN =================
#define SPAWN_X 1702.5
#define SPAWN_Y 328.5
#define SPAWN_Z 10.0
#define SPAWN_SKIN 26

// ================= PATH =================
stock ContaPath(playerid, path[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(path, size, "Contas/%s.ini", nome);
}

// ================= MENUS =================
stock AbrirPrefeitura(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_PREFEITURA, DIALOG_STYLE_LIST,
        "Prefeitura",
        "Ver Empregos\nSair do Emprego",
        "Selecionar", "Fechar");
    return 1;
}

stock AbrirGPS(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST,
        "GPS",
        "Prefeitura LS\nPrefeitura SF\nPrefeitura LV",
        "Marcar", "Cancelar");
    return 1;
}

// ================= CONNECT =================
public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    PlayerEmprego[playerid] = EMPREGO_NENHUM;
    TogglePlayerControllable(playerid, false);

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    if(dini_Exists(path))
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
            "Login", "Digite sua senha:", "Entrar", "Sair");
    else
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
            "Registro", "Crie sua senha:", "Registrar", "Sair");

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(!Logado[playerid]) return 1;

    new path[64];
    ContaPath(playerid, path, sizeof(path));
    dini_IntSet(path, "Emprego", PlayerEmprego[playerid]);
    return 1;
}

// ================= SPAWN =================
public OnPlayerSpawn(playerid)
{
    SetPlayerSkin(playerid, SPAWN_SKIN);
    SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    return 1;
}

// ================= DIALOG RESPONSE =================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(!response) return 1;

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    // LOGIN
    if(dialogid == DIALOG_LOGIN)
    {
        new senha[32];
        dini_Get(path, "Senha", senha);

        if(strcmp(inputtext, senha, false) != 0)
        {
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
                "Login", "Senha incorreta:", "Entrar", "Sair");
            return 1;
        }

        Logado[playerid] = true;
        PlayerEmprego[playerid] = dini_Int(path, "Emprego");

        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);
        return 1;
    }

    // REGISTRO
    if(dialogid == DIALOG_REGISTER)
    {
        dini_Create(path);
        dini_Set(path, "Senha", inputtext);
        dini_IntSet(path, "Emprego", EMPREGO_NENHUM);

        Logado[playerid] = true;
        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);
        return 1;
    }

    // MENU
    if(dialogid == DIALOG_MENU)
    {
        if(listitem == 0) AbrirPrefeitura(playerid);
        if(listitem == 1) AbrirGPS(playerid);
        return 1;
    }

    // PREFEITURA
    if(dialogid == DIALOG_PREFEITURA)
    {
        if(listitem == 0)
        {
            ShowPlayerDialog(playerid, DIALOG_EMPREGOS, DIALOG_STYLE_LIST,
                "Empregos",
                "Polícia\nSAMU\nTaxi\nMecânico",
                "Selecionar", "Voltar");
        }
        else if(listitem == 1)
        {
            PlayerEmprego[playerid] = EMPREGO_NENHUM;
            SendClientMessage(playerid, -1, "Você saiu do emprego.");
        }
        return 1;
    }

    // EMPREGOS
    if(dialogid == DIALOG_EMPREGOS)
    {
        PlayerEmprego[playerid] = listitem + 1;
        SendClientMessage(playerid, -1, "Emprego assumido com sucesso!");
        return 1;
    }

    // GPS
    if(dialogid == DIALOG_GPS)
    {
        DisablePlayerCheckpoint(playerid);

        switch(listitem)
        {
            case 0:
            {
                SetPlayerCheckpoint(playerid, 1555.0, -1675.0, 16.2, 5.0); // LS
                break;
            }
            case 1:
            {
                SetPlayerCheckpoint(playerid, -1987.0, 138.0, 27.6, 5.0); // SF
                break;
            }
            case 2:
            {
                SetPlayerCheckpoint(playerid, 1377.0, 2329.0, 10.8, 5.0); // LV
                break;
            }
            default:
            {
                return 1;
            }
        }

        SendClientMessage(playerid, 0x00FF00FF, "GPS marcado no mapa.");
        return 1;
    }

    return 1;
}

// ================= COMANDOS =================
CMD:menu(playerid)
{
    if(!Logado[playerid]) return 1;
    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,
        "Menu",
        "Prefeitura\nGPS",
        "Selecionar", "Fechar");
    return 1;
}

CMD:prefeitura(playerid)
{
    if(!Logado[playerid]) return 1;
    AbrirPrefeitura(playerid);
    return 1;
}

CMD:gps(playerid)
{
    if(!Logado[playerid]) return 1;
    AbrirGPS(playerid);
    return 1;
}

// ================= SALÁRIO =================
forward PagamentoSalario();
public PagamentoSalario()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Logado[i] && PlayerEmprego[i] != EMPREGO_NENHUM)
        {
            GivePlayerMoney(i, 1000);
            SendClientMessage(i, 0x00FF00FF, "Salário recebido.");
        }
    }
    return 1;
}

// ================= INIT =================
public OnGameModeInit()
{
    SetGameModeText("Cidade RP Full");
    SetTimer("PagamentoSalario", 600000, true);
    return 1;
}

// ================= COMANDO INVÁLIDO =================
public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if(!success)
    {
        SendClientMessage(playerid, 0xFF4444FF,
            "Comando inválido! Use /menu ou /ajuda para ver todos os comandos disponíveis.");
        return 1;
    }
    return 1;
}
