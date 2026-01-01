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

// Carregar comandos (Deve vir DEPOIS das definições de IDs)
#include "commands.inc" 

main() { print("Servidor Cidade RP 2026"); }

public OnGameModeInit() {
    AddPlayerClass(26, 1958.37, 1343.15, 15.37, 269.1, 0, 0, 0, 0, 0, 0);
    CreatePickup(1274, 1, 1467.0, -1010.0, 26.0, -1); // Banco LS
    CreatePickup(1274, 1, -2416.0, 508.0, 35.0, -1);  // Banco SF
    CreatePickup(1274, 1, 2372.0, 2311.0, 10.0, -1);  // Banco LV
    return 1;
}

stock ContaPath(playerid) {
    new name[MAX_PLAYER_NAME], path[128];
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
        new info[128];
        format(info, sizeof(info), "{FFFFFF}Saldo: {00FF00}$%d\n{FFFFFF}Escolha uma opção:", PlayerMoney[playerid]);
        ShowPlayerDialog(playerid, DIALOG_BANK_MENU, DIALOG_STYLE_LIST, "Banco Central", "Sacar\nDepositar", "Selecionar", "Fechar");
    }
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    // ESSA FUNÇÃO PRECISA EXISTIR NO COMMANDS.INC
    if (HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext)) return 1;

    if(dialogid == DIALOG_REGISTER) {
        if(!response) return Kick(playerid);
        dini_Create(ContaPath(playerid));
        dini_Set(ContaPath(playerid), "Senha", inputtext);
        dini_IntSet(ContaPath(playerid), "DinheiroBanco", 0);
        Logado[playerid] = true;
        SpawnPlayer(playerid);
        return 1;
    }

    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        new pass[128];
        format(pass, sizeof(pass), dini_Get(ContaPath(playerid), "Senha"));
        if(strcmp(inputtext, pass) == 0) {
            PlayerMoney[playerid] = dini_Int(ContaPath(playerid), "DinheiroBanco");
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

    if(dialogid == DIALOG_BANK_SACAR && response) {
        new q = strval(inputtext);
        if(q <= 0 || q > PlayerMoney[playerid]) return SendClientMessage(playerid, -1, "Saldo insuficiente!");
        PlayerMoney[playerid] -= q;
        GivePlayerMoney(playerid, q);
        return 1;
    }

    if(dialogid == DIALOG_BANK_DEPOSITAR && response) {
        new q = strval(inputtext);
        if(q <= 0 || q > GetPlayerMoney(playerid)) return SendClientMessage(playerid, -1, "Você não tem esse dinheiro!");
        PlayerMoney[playerid] += q;
        GivePlayerMoney(playerid, -q);
        return 1;
    }

    if(dialogid == DIALOG_GPS_MENU && response) {
        switch(listitem) {
            case 0: ShowPlayerDialog(playerid, DIALOG_GPS_LS, DIALOG_STYLE_LIST, "Los Santos", "Prefeitura\nBanco\nDP", "Marcar", "Voltar");
            case 1: ShowPlayerDialog(playerid, DIALOG_GPS_SF, DIALOG_STYLE_LIST, "San Fierro", "Banco\nDP", "Marcar", "Voltar");
            case 2: ShowPlayerDialog(playerid, DIALOG_GPS_LV, DIALOG_STYLE_LIST, "Las Venturas", "Banco\nDP", "Marcar", "Voltar");
        }
        return 1;
    }

    if(dialogid >= 501 && dialogid <= 503 && response) {
        DisablePlayerCheckpoint(playerid);
        if(dialogid == DIALOG_GPS_LS) {
            if(listitem == 0) SetPlayerCheckpoint(playerid, 1481.0, -1741.0, 13.5, 4.0);
            if(listitem == 1) SetPlayerCheckpoint(playerid, 1467.0, -1010.0, 26.0, 4.0);
        }
        // Adicionar SF e LV aqui seguindo o modelo acima
        SendClientMessage(playerid, -1, "Local marcado!");
        return 1;
    }
    return 0;
}

public OnPlayerDisconnect(playerid, reason) {
    if(Logado[playerid]) {
        dini_IntSet(ContaPath(playerid), "DinheiroBanco", PlayerMoney[playerid]);
    }
    return 1;
}

public OnPlayerSpawn(playerid) {
    if(!Logado[playerid]) Kick(playerid);
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success) {
    if(!success) SendClientMessage(playerid, -1, "Comando inexistente. Use /gps");
    return 1;
}
