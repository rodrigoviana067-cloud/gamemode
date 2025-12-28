#include <a_samp>
#include <zcmd>
#include <sscanf2>
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
#define EMPREGO_MEC     4

// ================= VARIÁVEIS =================
new bool:Logado[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];
new bool:EmServico[MAX_PLAYERS];

// ================= SPAWN =================
#define SPAWN_X 1702.5
#define SPAWN_Y 328.5
#define SPAWN_Z 10.0

// ================= PATH =================
stock ContaPath(playerid, path[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(path, size, "Contas/%s.ini", nome);
}

// ================= CIDADE =================
stock GetPlayerCidade(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    if(x > 44.0 && x < 2997.0 && y > -2892.0 && y < -768.0) return 1; // LS
    if(x < -44.0 && y < 2997.0) return 2; // SF
    if(x > 44.0 && y > 768.0) return 3; // LV

    return 0;
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

// ================= DIALOGS =================
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

        if(strcmp(inputtext, senha, false))
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
        if(listitem == 0) cmd_prefeitura(playerid);
        if(listitem == 1) cmd_gps(playerid);
        return 1;
    }

    // PREFEITURA
    if(dialogid == DIALOG_PREFEITURA)
    {
        if(listitem == 0)
            ShowPlayerDialog(playerid, DIALOG_EMPREGOS, DIALOG_STYLE_LIST,
            "Empregos", "Polícia\nSAMU\nTaxi\nMecânico", "Selecionar", "Voltar");

        if(listitem == 1)
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
        SendClientMessage(playerid, -1, "Emprego assumido!");
        return 1;
    }

    // GPS
    if(dialogid == DIALOG_GPS)
    {
        SetPlayerCheckpoint(playerid, 1555.0, -1675.0, 16.2, 5.0);
        return 1;
    }

    return 1;
}

// ================= COMANDOS =================
CMD:menu(playerid)
{
    if(!Logado[playerid]) return 1;

    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,
    "Menu", "Prefeitura\nGPS", "Selecionar", "Fechar");
    return 1;
}

CMD:prefeitura(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_PREFEITURA, DIALOG_STYLE_LIST,
    "Prefeitura", "Ver Empregos\nSair do Emprego", "Selecionar", "Fechar");
    return 1;
}

CMD:gps(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST,
    "GPS", "Prefeitura", "Marcar", "Cancelar");
    return 1;
}

// ================= SALÁRIO =================
forward PagamentoSalario();
public PagamentoSalario()
{
    for(new i; i < MAX_PLAYERS; i++)
    {
        if(Logado[i] && PlayerEmprego[i] != EMPREGO_NENHUM)
            GivePlayerMoney(i, 1000);
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
