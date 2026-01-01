#include <a_samp>
#include <zcmd>
#include <dini>

// Definições de IDs
#define DIALOG_LOGIN        1
#define DIALOG_REGISTER     2
#define DIALOG_GPS_MENU     500
#define DIALOG_GPS_LS       501
#define DIALOG_GPS_SF       502
#define DIALOG_GPS_LV       503
#define DIALOG_GPS_EMPREGOS 504
#define DIALOG_GPS_LOJAS    505
#define DIALOG_BANK_MENU    600
#define DIALOG_BANK_SACAR   601
#define DIALOG_BANK_DEPOSITAR 602

#define EMPREGO_NENHUM      0

// Variáveis Globais
new bool:Logado[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];
new PlayerMoney[MAX_PLAYERS];

#include "commands.inc" 

main() { print("Servidor Cidade RP 2026 Carregado"); }

public OnGameModeInit() {
    AddPlayerClass(26, 1958.37, 1343.15, 15.37, 269.1, 0, 0, 0, 0, 0, 0);
    // Pickup do Banco (ID 1274 - Cofre)
    CreatePickup(1274, 1, 1467.0, -1010.0, 26.0, -1); 
    return 1;
}

stock ContaPath(playerid) {
    new name[MAX_PLAYER_NAME], path[64];
    GetPlayerName(playerid, name, sizeof(name));
    format(path, sizeof(path), "contas/%s.ini", name);
    return path;
}

public OnPlayerConnect(playerid) {
    Logado[playerid] = false;
    SetTimerEx("MostrarLogin", 1000, false, "i", playerid);
    return 1;
}

forward MostrarLogin(playerid);
public MostrarLogin(playerid) {
    if (dini_Exists(ContaPath(playerid))) {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Digite sua senha:", "Entrar", "Sair");
    } else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registro", "Crie uma senha:", "Registrar", "Sair");
    }
}

public OnPlayerPickUpPickup(playerid, pickupid) {
    if(Logado[playerid]) {
        new info[256];
        format(info, sizeof(info), "{FFFFFF}Saldo: {00FF00}$%d\n{FFFFFF}Escolha uma opção:", PlayerMoney[playerid]);
        ShowPlayerDialog(playerid, DIALOG_BANK_MENU, DIALOG_STYLE_LIST, "Banco", "Sacar\nDepositar", "Selecionar", "Fechar");
    }
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if (HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext)) return 1;

    if(dialogid == DIALOG_REGISTER) {
        if(!response) return Kick(playerid);
        dini_Create(ContaPath(playerid));
        dini_Set(ContaPath(playerid), "Senha", inputtext);
        dini_IntSet(ContaPath(playerid), "Dinheiro", 0);
        Logado[playerid] = true;
        SpawnPlayer(playerid);
        return 1;
    }

    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        if(strcmp(inputtext, dini_Get(ContaPath(playerid), "Senha")) == 0) {
            PlayerMoney[playerid] = dini_Int(ContaPath(playerid), "Dinheiro");
            Logado[playerid] = true;
            SpawnPlayer(playerid);
        } else MostrarLogin(playerid);
        return 1;
    }

    if(dialogid == DIALOG_BANK_MENU && response) {
        if(listitem == 0) ShowPlayerDialog(playerid, DIALOG_BANK_SACAR, DIALOG_STYLE_INPUT, "Sacar", "Quantia:", "Sacar", "Voltar");
        if(listitem == 1) ShowPlayerDialog(playerid, DIALOG_BANK_DEPOSITAR, DIALOG_STYLE_INPUT, "Depositar", "Quantia:", "Depositar", "Voltar");
        return 1;
    }

    if(dialogid == DIALOG_GPS_MENU && response) {
        if(listitem == 0) SetPlayerCheckpoint(playerid, 1481.0, -1741.0, 13.5, 4.0); // Exemplo: Prefeitura LS
        SendClientMessage(playerid, -1, "Local marcado no GPS!");
        return 1;
    }
    return 0;
}

public OnPlayerDisconnect(playerid, reason) {
    if(Logado[playerid]) {
        dini_IntSet(ContaPath(playerid), "Dinheiro", PlayerMoney[playerid]);
    }
    return 1;
}

public OnPlayerSpawn(playerid) {
    if(!Logado[playerid]) Kick(playerid);
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success) {
    if(!success) SendClientMessage(playerid, -1, "{FF0000}Erro: {FFFFFF}Comando inexistente. Use /gps");
    return 1;
}
