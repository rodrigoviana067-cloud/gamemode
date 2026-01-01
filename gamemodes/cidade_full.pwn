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
#define DIALOG_BANK_MENU    600
#define DIALOG_BANK_SACAR   601
#define DIALOG_BANK_DEPOSITAR 602

// Variáveis Globais
new bool:Logado[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];
new PlayerMoney[MAX_PLAYERS];

// Forward para o include reconhecer
forward HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext[]);

#include "commands.inc" 

main() { print("Servidor Cidade RP 2026 Carregado"); }

public OnGameModeInit() {
    AddPlayerClass(26, 1958.37, 1343.15, 15.37, 269.1, 0, 0, 0, 0, 0, 0);
    CreatePickup(1274, 1, 1467.0, -1010.0, 26.0, -1); // Pickup Banco
    return 1;
}

// Função de caminho da conta corrigida (sem erros de argumento)
stock GetConta(playerid) {
    new str[64], name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), "contas/%s.ini", name);
    return str;
}

public OnPlayerConnect(playerid) {
    Logado[playerid] = false;
    // Timer para garantir que a tela carregue antes do login
    SetTimerEx("MostrarLogin", 1500, false, "i", playerid);
    return 1;
}

forward MostrarLogin(playerid);
public MostrarLogin(playerid) {
    if (dini_Exists(GetConta(playerid))) {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{00CCFF}Login", "Digite sua senha para entrar:", "Entrar", "Sair");
    } else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{00CCFF}Registro", "Crie uma senha para sua nova conta:", "Registrar", "Sair");
    }
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if (HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext)) return 1;

    if(dialogid == DIALOG_REGISTER) {
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 4) return MostrarLogin(playerid);
        
        dini_Create(GetConta(playerid));
        dini_Set(GetConta(playerid), "Senha", inputtext);
        dini_IntSet(GetConta(playerid), "DinheiroBanco", 0);
        dini_IntSet(GetConta(playerid), "Emprego", 0);
        
        Logado[playerid] = true;
        SpawnPlayer(playerid);
        return 1;
    }

    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        
        new senha_ini[64];
        format(senha_ini, sizeof(senha_ini), dini_Get(GetConta(playerid), "Senha"));

        if(!strcmp(inputtext, senha_ini)) {
            PlayerMoney[playerid] = dini_Int(GetConta(playerid), "DinheiroBanco");
            PlayerEmprego[playerid] = dini_Int(GetConta(playerid), "Emprego");
            Logado[playerid] = true;
            SpawnPlayer(playerid);
        } else {
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Erro", "Senha incorreta!", "Entrar", "Sair");
        }
        return 1;
    }

    // Lógica do Banco via Pickup
    if(dialogid == DIALOG_BANK_MENU && response) {
        if(listitem == 0) ShowPlayerDialog(playerid, DIALOG_BANK_SACAR, DIALOG_STYLE_INPUT, "Sacar", "Quantia:", "Sacar", "Voltar");
        if(listitem == 1) ShowPlayerDialog(playerid, DIALOG_BANK_DEPOSITAR, DIALOG_STYLE_INPUT, "Depositar", "Quantia:", "Depositar", "Voltar");
        return 1;
    }

    // Lógica do GPS (Sub-menus)
    if(dialogid == DIALOG_GPS_MENU && response) {
        if(listitem == 0) ShowPlayerDialog(playerid, DIALOG_GPS_LS, DIALOG_STYLE_LIST, "Los Santos", "Prefeitura\nBanco\nDP", "Marcar", "Voltar");
        if(listitem == 3) DisablePlayerCheckpoint(playerid);
        return 1;
    }
    
    if(dialogid == DIALOG_GPS_LS && response) {
        if(listitem == 0) SetPlayerCheckpoint(playerid, 1481.0, -1741.0, 13.5, 4.0);
        SendClientMessage(playerid, -1, "Local marcado!");
        return 1;
    }
    return 0;
}

public OnPlayerPickUpPickup(playerid, pickupid) {
    if(Logado[playerid]) {
        new str[128];
        format(str, sizeof(str), "{FFFFFF}Saldo: {00FF00}$%d\n{FFFFFF}Escolha uma opção:", PlayerMoney[playerid]);
        ShowPlayerDialog(playerid, DIALOG_BANK_MENU, DIALOG_STYLE_LIST, "Banco Central", "Sacar\nDepositar", "Selecionar", "Fechar");
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    if(Logado[playerid]) {
        dini_IntSet(GetConta(playerid), "DinheiroBanco", PlayerMoney[playerid]);
        dini_IntSet(GetConta(playerid), "Emprego", PlayerEmprego[playerid]);
    }
    return 1;
}

public OnPlayerSpawn(playerid) {
    if(!Logado[playerid]) return Kick(playerid);
    return 1;
}
