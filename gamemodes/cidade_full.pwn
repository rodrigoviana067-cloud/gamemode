#include <a_samp>
#include <zcmd>
#include <dini>

// IDs
#define DIALOG_LOGIN        1
#define DIALOG_REGISTER     2
#define DIALOG_GPS_MENU     500
#define DIALOG_GPS_LS       501
#define DIALOG_GPS_SF       502
#define DIALOG_GPS_LV       503
#define DIALOG_BANK_MENU    600
#define DIALOG_BANK_SACAR   601
#define DIALOG_BANK_DEPOSITAR 602

// Variáveis
new bool:Logado[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];
new PlayerMoney[MAX_PLAYERS];

// AQUI: Declare para o compilador saber que ela existe no include
forward HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext[]);

#include "commands.inc" 

main() { print("Servidor Cidade RP 2026 Online"); }

// ... (OnGameModeInit, OnPlayerConnect, etc permanecem iguais)

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    // Chamar a função do include
    if (HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext)) return 1;

    new path[64];
    GetPlayerName(playerid, path, 24); // Reuso da variável para economizar
    format(path, sizeof(path), "contas/%s.ini", path);

    // LOGIN
    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        new pass[64];
        format(pass, 64, dini_Get(path, "Senha"));
        if(!strcmp(inputtext, pass)) {
            PlayerMoney[playerid] = dini_Int(path, "DinheiroBanco");
            PlayerEmprego[playerid] = dini_Int(path, "Emprego"); // RESOLVE O WARNING
            Logado[playerid] = true;
            SpawnPlayer(playerid);
        } else ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Senha Incorreta!", "Entrar", "Sair");
        return 1;
    }

    // BANCO (PICKUP)
    if(dialogid == DIALOG_BANK_MENU && response) {
        if(listitem == 0) ShowPlayerDialog(playerid, DIALOG_BANK_SACAR, DIALOG_STYLE_INPUT, "Sacar", "Quanto deseja sacar?", "Sacar", "Voltar");
        if(listitem == 1) ShowPlayerDialog(playerid, DIALOG_BANK_DEPOSITAR, DIALOG_STYLE_INPUT, "Depositar", "Quanto deseja depositar?", "Dep.", "Voltar");
        return 1;
    }
    
    // GPS LÓGICA
    if(dialogid == DIALOG_GPS_MENU && response) {
        if(listitem == 0) ShowPlayerDialog(playerid, DIALOG_GPS_LS, DIALOG_STYLE_LIST, "Los Santos", "Prefeitura\nBanco\nDP", "Marcar", "Voltar");
        if(listitem == 1) ShowPlayerDialog(playerid, DIALOG_GPS_SF, DIALOG_STYLE_LIST, "San Fierro", "Banco\nDP", "Marcar", "Voltar");
        if(listitem == 2) ShowPlayerDialog(playerid, DIALOG_GPS_LV, DIALOG_STYLE_LIST, "Las Venturas", "Banco\nDP", "Marcar", "Voltar");
        return 1;
    }
    
    // CHECKPOINTS (LS, SF, LV)
    if(dialogid >= 501 && dialogid <= 503 && response) {
        DisablePlayerCheckpoint(playerid);
        if(dialogid == DIALOG_GPS_LS) {
            if(listitem == 0) SetPlayerCheckpoint(playerid, 1481.0, -1741.0, 13.5, 4.0);
            if(listitem == 1) SetPlayerCheckpoint(playerid, 1467.0, -1010.0, 26.0, 4.0);
        }
        SendClientMessage(playerid, -1, "{00FF00}GPS: {FFFFFF}Local marcado!");
        return 1;
    }
    return 0;
}

public OnPlayerDisconnect(playerid, reason) {
    if(Logado[playerid]) {
        new name[24], f[64];
        GetPlayerName(playerid, name, 24);
        format(f, 64, "contas/%s.ini", name);
        dini_IntSet(f, "DinheiroBanco", PlayerMoney[playerid]);
        dini_IntSet(f, "Emprego", PlayerEmprego[playerid]); // RESOLVE O WARNING
    }
    return 1;
}
