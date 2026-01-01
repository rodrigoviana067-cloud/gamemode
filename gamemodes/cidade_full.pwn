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

    // --- SISTEMA DE GPS COMPLETO ---
    if(dialogid == DIALOG_GPS_MENU && response) {
        switch(listitem) {
            case 0: ShowPlayerDialog(playerid, DIALOG_GPS_LS, DIALOG_STYLE_LIST, "GPS - Los Santos", "Prefeitura\nBanco Central\nDP\nHospital\nAeroporto", "Marcar", "Voltar");
            case 1: ShowPlayerDialog(playerid, DIALOG_GPS_SF, DIALOG_STYLE_LIST, "GPS - San Fierro", "Banco SF\nDP SF\nHospital SF\nAeroporto SF", "Marcar", "Voltar");
            case 2: ShowPlayerDialog(playerid, DIALOG_GPS_LV, DIALOG_STYLE_LIST, "GPS - Las Venturas", "Banco LV\nCassino\nDP LV\nAeroporto LV", "Marcar", "Voltar");
            case 3: ShowPlayerDialog(playerid, DIALOG_GPS_EMPREGOS, DIALOG_STYLE_LIST, "GPS - Empregos", "Caminhoneiro\nTaxista\nPizza\nLixeiro", "Marcar", "Voltar");
            case 4: ShowPlayerDialog(playerid, DIALOG_GPS_LOJAS, DIALOG_STYLE_LIST, "GPS - Lojas", "Concessionaria\nAmmu-Nation\n24/7\nMecanica", "Marcar", "Voltar");
            case 5: { DisablePlayerCheckpoint(playerid); SendClientMessage(playerid, -1, "GPS Desativado."); }
        }
        return 1;
    }

    // Processamento dos Sub-Menus (Marcação do Ponto Vermelho)
    if(dialogid >= 501 && dialogid <= 505) {
        if(!response) { new t[1]; return cmd_gps(playerid, t); } // Botão Voltar
        DisablePlayerCheckpoint(playerid);
        
        switch(dialogid) {
            case DIALOG_GPS_LS: {
                if(listitem == 0) SetPlayerCheckpoint(playerid, 1481.0, -1741.0, 13.5, 4.0);
                else if(listitem == 1) SetPlayerCheckpoint(playerid, 1467.0, -1010.0, 26.0, 4.0);
                else if(listitem == 2) SetPlayerCheckpoint(playerid, 1543.0, -1675.0, 13.5, 4.0);
                else if(listitem == 3) SetPlayerCheckpoint(playerid, 1172.0, -1323.0, 14.0, 4.0);
                else if(listitem == 4) SetPlayerCheckpoint(playerid, 1958.0, -2173.0, 13.5, 4.0);
            }
            case DIALOG_GPS_SF: {
                if(listitem == 0) SetPlayerCheckpoint(playerid, -2416.0, 508.0, 35.0, 4.0);
                else if(listitem == 1) SetPlayerCheckpoint(playerid, -1605.0, 711.0, 13.0, 4.0);
                else if(listitem == 2) SetPlayerCheckpoint(playerid, -2646.0, 630.0, 14.0, 4.0);
                else if(listitem == 3) SetPlayerCheckpoint(playerid, -1420.0, -287.0, 14.0, 4.0);
            }
            case DIALOG_GPS_LV: {
                if(listitem == 0) SetPlayerCheckpoint(playerid, 2372.0, 2311.0, 10.0, 4.0);
                else if(listitem == 1) SetPlayerCheckpoint(playerid, 2191.0, 1677.0, 12.0, 4.0);
                else if(listitem == 2) SetPlayerCheckpoint(playerid, 2290.0, 2431.0, 10.0, 4.0);
                else if(listitem == 3) SetPlayerCheckpoint(playerid, 1585.0, 1445.0, 10.0, 4.0);
            }
            case DIALOG_GPS_EMPREGOS: {
                if(listitem == 0) SetPlayerCheckpoint(playerid, 2458.0, -2121.0, 13.5, 4.0);
                else if(listitem == 1) SetPlayerCheckpoint(playerid, 1782.0, -1153.0, 23.0, 4.0);
                else if(listitem == 2) SetPlayerCheckpoint(playerid, 2105.0, -1806.0, 13.5, 4.0);
                else if(listitem == 3) SetPlayerCheckpoint(playerid, 2185.0, -1974.0, 13.5, 4.0);
            }
            case DIALOG_GPS_LOJAS: {
                if(listitem == 0) SetPlayerCheckpoint(playerid, 2131.0, -1150.0, 24.0, 4.0);
                else if(listitem == 1) SetPlayerCheckpoint(playerid, 1368.0, -1279.0, 13.5, 4.0);
                else if(listitem == 2) SetPlayerCheckpoint(playerid, 1315.0, -897.0, 39.5, 4.0);
                else if(listitem == 3) SetPlayerCheckpoint(playerid, 2439.0, -1471.0, 24.0, 4.0);
            }
        }
        SendClientMessage(playerid, -1, "{FFFF00}GPS: {FFFFFF}Local marcado! Siga o ponto vermelho no radar.");
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
