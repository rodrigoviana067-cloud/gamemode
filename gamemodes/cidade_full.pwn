#include <a_samp>
#include <zcmd>
#include <dini>

// Definições de IDs de Diálogo
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
    // Pickups dos Bancos (ID 1274 - Cofre)
    CreatePickup(1274, 1, 1467.0, -1010.0, 26.0, -1); // LS
    CreatePickup(1274, 1, -2416.0, 508.0, 35.0, -1);  // SF
    CreatePickup(1274, 1, 2372.0, 2311.0, 10.0, -1);  // LV
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

public OnPlayerRequestClass(playerid, classid) {
    if(Logado[playerid]) {
        SpawnPlayer(playerid);
        return 1;
    }
    // Posição de câmera enquanto loga
    SetPlayerPos(playerid, 1550.0, -1600.0, 30.0);
    SetPlayerCameraPos(playerid, 1550.0, -1650.0, 50.0);
    SetPlayerCameraLookAt(playerid, 1550.0, -1600.0, 30.0);
    return 1;
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
        dini_IntSet(ContaPath(playerid), "DinheiroBanco", 0);
        Logado[playerid] = true;
        GivePlayerMoney(playerid, 500); // Dinheiro inicial no bolso
        SpawnPlayer(playerid);
        return 1;
    }

    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        if(strcmp(inputtext, dini_Get(ContaPath(playerid), "Senha")) == 0) {
            PlayerMoney[playerid] = dini_Int(ContaPath(playerid), "DinheiroBanco");
            Logado[playerid] = true;
            GivePlayerMoney(playerid, 500); // Dinheiro inicial no bolso
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
        new quantia = strval(inputtext);
        if (quantia <= 0 || quantia > PlayerMoney[playerid]) return SendClientMessage(playerid, -1, "{FF0000}Valor inválido ou insuficiente!");
        PlayerMoney[playerid] -= quantia;
        GivePlayerMoney(playerid, quantia);
        SendClientMessage(playerid, -1, "{00FF00}Você sacou R$ %d.", quantia);
        return 1;
    }
    if(dialogid == DIALOG_BANK_DEPOSITAR && response) {
        new quantia = strval(inputtext);
        if (quantia <= 0 || quantia > GetPlayerMoney(playerid)) return SendClientMessage(playerid, -1, "{FF0000}Valor inválido ou insuficiente no bolso!");
        PlayerMoney[playerid] += quantia;
        GivePlayerMoney(playerid, -quantia);
        SendClientMessage(playerid, -1, "{00FF00}Você depositou R$ %d.", quantia);
        return 1;
    }
    

    // --- LÓGICA COMPLETA DOS SUB-MENUS GPS ---
    if(dialogid == DIALOG_GPS_MENU) {
        if(!response) return 1;
        if(listitem == 0) ShowPlayerDialog(playerid, DIALOG_GPS_LS, DIALOG_STYLE_LIST, "GPS - Los Santos", "Prefeitura\nBanco Central\nDP\nHospital\nAeroporto", "Marcar", "Voltar");
        if(listitem == 1) ShowPlayerDialog(playerid, DIALOG_GPS_SF, DIALOG_STYLE_LIST, "GPS - San Fierro", "Banco SF\nDP SF\nHospital SF\nAeroporto SF", "Marcar", "Voltar");
        if(listitem == 2) ShowPlayerDialog(playerid, DIALOG_GPS_LV, DIALOG_STYLE_LIST, "GPS - Las Venturas", "Banco LV\nCassino\nDP LV\nAeroporto LV", "Marcar", "Voltar");
        if(listitem == 3) ShowPlayerDialog(playerid, DIALOG_GPS_EMPREGOS, DIALOG_STYLE_LIST, "GPS - Empregos", "Caminhoneiro\nTaxista\nPizza\nLixeiro", "Marcar", "Voltar");
        if(listitem == 4) ShowPlayerDialog(playerid, DIALOG_GPS_LOJAS, DIALOG_STYLE_LIST, "GPS - Lojas", "Concessionaria\nAmmu-Nation\n24/7\nMecanica", "Marcar", "Voltar");
        if(listitem == 5) DisablePlayerCheckpoint(playerid);
        return 1;
    }

    if(dialogid >= 501 && dialogid <= 505) {
        if(!response) { new t; return cmd_gps(playerid, t); } // Voltar ao menu principal GPS
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
        SendClientMessage(playerid, -1, "{FFFF00}GPS: {FFFFFF}Local marcado no seu mapa!");
        return 1;
    }
    return 0;
}

public OnPlayerDisconnect(playerid, reason) {
    if(Logado[playerid]) {
        dini_IntSet(ContaPath(playerid), "DinheiroBanco", PlayerMoney[playerid]);
        // Note: Posição e Emprego não estão salvando aqui, precisa adicionar GetPlayerPos
    }
    return 1;
}

public OnPlayerSpawn(playerid) {
    if(!Logado[playerid]) Kick(playerid);
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    DisablePlayerCheckpoint(playerid);
    SendClientMessage(playerid, -1, "{00FF00}GPS: {FFFFFF}Você chegou ao seu destino final.");
    PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success) {
    if(!success) SendClientMessage(playerid, -1, "{FF0000}Erro: {FFFFFF}Comando inexistente. Use /gps");
    return 1;
}
