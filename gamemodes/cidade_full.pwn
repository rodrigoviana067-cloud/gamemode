#include <a_samp>
#include <dini>
#include <zcmd>
#include <sscanf2>

// ================= DIALOGS =================
#define DIALOG_LOGIN    1
#define DIALOG_REGISTER 2
#define DIALOG_MENU     100
#define DIALOG_GPS      200
#define EMPREGO_NENHUM   0
#define EMPREGO_POLICIA  1
#define EMPREGO_SAMU     2
#define EMPREGO_TAXI     3
#define EMPREGO_MEC     4
#define PREF_LS_X 1481.0
#define PREF_LS_Y -1771.0
#define PREF_LS_Z 18.8
#define DIALOG_PREFEITURA 400
#define DIALOG_EMPREGOS   401
#define DIALOG_EMPREGOS 300

#define PREF_SF_X -2765.0
#define PREF_SF_Y 375.0
#define PREF_SF_Z 6.3

#define PREF_LV_X 1382.0
#define PREF_LV_Y 5.9
#define PREF_LV_Z 1000.9

// ================= VARIÁVEIS =================
new bool:Logado[MAX_PLAYERS];
new TemCelular[MAX_PLAYERS];
new PlayerAdmin[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];
new bool:GPSAtivo[MAX_PLAYERS];
new bool:EmServico[MAX_PLAYERS];

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
PlayerEmprego[playerid] = dini_Int(path, "Emprego");

    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(path, size, "Contas/%s.ini", nome);
}

stock GetPlayerCidade(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // LOS SANTOS
    if(x > 44.0 && x < 2997.0 && y > -2892.0 && y < -768.0)
        return 1;

    // SAN FIERRO
    if(x > -2997.0 && x < -44.0 && y > -768.0 && y < 2997.0)
        return 2;

    // LAS VENTURAS
    if(x > 44.0 && x < 2997.0 && y > 768.0 && y < 2997.0)
        return 3;

    return 0;
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
// ===== PREFEITURA =====
if(dialogid == DIALOG_PREFEITURA)
{
    if(listitem == 0) // Ver empregos
    {
        new cidade = GetPlayerCidade(playerid);

        if(cidade == 1)
            ShowPlayerDialog(playerid, DIALOG_EMPREGOS, DIALOG_STYLE_LIST,
                "Empregos - Los Santos",
                "Polícia LS\nSAMU LS\nTaxista LS\nMecânico LS",
                "Selecionar", "Voltar");

        else if(cidade == 2)
            ShowPlayerDialog(playerid, DIALOG_EMPREGOS, DIALOG_STYLE_LIST,
                "Empregos - San Fierro",
                "Polícia SF\nSAMU SF\nTaxista SF\nMecânico SF",
                "Selecionar", "Voltar");

        else if(cidade == 3)
            ShowPlayerDialog(playerid, DIALOG_EMPREGOS, DIALOG_STYLE_LIST,
                "Empregos - Las Venturas",
                "Polícia LV\nSAMU LV\nTaxista LV\nMecânico LV",
                "Selecionar", "Voltar");

        return 1;
forward PagamentoSalario();
public PagamentoSalario()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Logado[i] && EmServico[i])
        {
            new salario = 0;

            switch(PlayerEmprego[i])
            {
                case EMPREGO_POLICIA: salario = 1500;
                case EMPREGO_SAMU:    salario = 1300;
                case EMPREGO_TAXI:    salario = 1000;
                case EMPREGO_MEC:     salario = 1200;
            }

            if(salario > 0)
            {
                GivePlayerMoney(i, salario);
                SendClientMessage(i, 0x00FF00FF,
                    "Salário recebido pelo seu serviço.");
            }
        }
    }
    return 1;
}

    }
if(dialogid == DIALOG_EMPREGOS)
{
    if(PlayerEmprego[playerid] != EMPREGO_NENHUM)
    {
        SendClientMessage(playerid, 0xFF0000FF,
            "Você já possui um emprego.");
        return 1;
    }

    PlayerEmprego[playerid] = listitem + 1;

    SendClientMessage(playerid, 0x00FF00FF,
        "Emprego assumido com sucesso!");
    SendClientMessage(playerid, -1,
        "Use /trabalhar futuramente.");

    return 1;
}


    if(listitem == 1) // Sair do emprego
    {
        PlayerEmprego[playerid] = EMPREGO_NENHUM;
        SendClientMessage(playerid, 0x00FF00FF,
            "Você saiu do seu emprego.");
        return 1;
    }
}

// ===== MENU =====
if(dialogid == DIALOG_MENU)
{
    if(listitem == 0) // Empregos
    {
        new cidade = GetPlayerCidade(playerid);

        if(cidade == 1)
        {
            ShowPlayerDialog(playerid, DIALOG_EMPREGOS, DIALOG_STYLE_LIST,
                "Empregos - Los Santos",
                "Polícia LS\nSAMU LS\nTaxista LS\nMecânico LS",
                "Selecionar", "Voltar");
        }
        else if(cidade == 2)
        {
            ShowPlayerDialog(playerid, DIALOG_EMPREGOS, DIALOG_STYLE_LIST,
                "Empregos - San Fierro",
                "Polícia SF\nSAMU SF\nTaxista SF\nMecânico SF",
                "Selecionar", "Voltar");
        }
        else if(cidade == 3)
        {
            ShowPlayerDialog(playerid, DIALOG_EMPREGOS, DIALOG_STYLE_LIST,
                "Empregos - Las Venturas",
                "Polícia LV\nSAMU LV\nTaxista LV\nMecânico LV",
                "Selecionar", "Voltar");
        }
        else
        {
            SendClientMessage(playerid, 0xFF0000FF, "Você não está em uma cidade válida.");
        }
        return 1;
    }
}

if(dialogid == DIALOG_EMPREGOS)
{
    SendClientMessage(playerid, 0x00FF00FF,
        "Vá até a prefeitura da cidade para assumir este emprego.");
    return 1;
}

    if(!response) return Kick(playerid);

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    // ===== REGISTRO =====
    if(dialogid == DIALOG_REGISTER)
    {
dini_IntSet(path, "Emprego", EMPREGO_NENHUM);
PlayerEmprego[playerid] = EMPREGO_NENHUM;

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

CMD:menu(playerid)
{
    if(!Logado[playerid]) return 0;

    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,
        "Menu da Cidade",
        "Empregos\nGPS\nCasas",
        "Selecionar", "Fechar");
    return 1;
CMD:prefeitura(playerid)
{
    if(!Logado[playerid]) return 0;

    new cidade = GetPlayerCidade(playerid);

    if(cidade == 0)
    {
        SendClientMessage(playerid, 0xFF0000FF,
            "Você não está em uma prefeitura.");
        return 1;
    }

    ShowPlayerDialog(playerid, 400, DIALOG_STYLE_LIST,
        "Prefeitura",
        "Ver empregos\nSair do emprego",
        "Selecionar", "Fechar");
    return 1;
}

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
dini_IntSet(path, "Emprego", PlayerEmprego[playerid]);
}

// ================= INIT =================
public OnGameModeInit()
{
    SetGameModeText("Cidade RP Full");
    return 1;
SetTimer("PagamentoSalario", 600000, true); // 10 minutos

}
