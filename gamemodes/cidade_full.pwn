#include <a_samp>
#include <zcmd>
#include <dini>

// Definições de IDs
#define DIALOG_LOGIN 1
#define DIALOG_REGISTER 2
#define DIALOG_MENU_PRINCIPAL 3
#define DIALOG_PREFEITURA 4
#define EMPREGO_NENHUM 0
#define DIALOG_GPS_MENU 500
#define DIALOG_GPS_LS   501
#define DIALOG_GPS_SF   502
#define DIALOG_GPS_LV   503

// Variáveis Globais
new bool:Logado[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];

// Carregar comandos externos (Certifique-se que o comando CMD:gps está aqui ou no fim deste arquivo)
#include "commands.inc" 

main() { 
    print("----------------------------------");
    print(" Servidor Cidade RP Iniciado 2026 ");
    print("----------------------------------");
}

public OnGameModeInit() {
    AddPlayerClass(26, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
    return 1;
}

stock ContaPath(playerid, buffer[], len) {
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(buffer, len, "contas/%s.ini", name);
}

public OnPlayerConnect(playerid) {
    Logado[playerid] = false;
    SetTimerEx("MostrarLogin", 1000, false, "i", playerid);
    return 1;
}

forward MostrarLogin(playerid);
public MostrarLogin(playerid) {
    new path[64];
    ContaPath(playerid, path, sizeof(path));
    if (dini_Exists(path)) {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login - Cidade RP", "Digite sua senha abaixo:", "Entrar", "Sair");
    } else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registro - Cidade RP", "Crie uma senha:", "Registrar", "Sair");
    }
}

public OnPlayerRequestClass(playerid, classid) {
    if(Logado[playerid] == true) {
        SpawnPlayer(playerid);
        return 1;
    }
    SetPlayerPos(playerid, 1550.0, -1600.0, 30.0);
    SetPlayerCameraPos(playerid, 1550.0, -1650.0, 50.0);
    SetPlayerCameraLookAt(playerid, 1550.0, -1600.0, 30.0);
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    // Processa comandos externos
    if (HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext)) return 1;

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    // Lógica de Registro
    if(dialogid == DIALOG_REGISTER) {
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 4) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Erro", "Senha muito curta!", "Registrar", "Sair");
        
        dini_Create(path);
        dini_Set(path, "Senha", inputtext);
        dini_IntSet(path, "Emprego", EMPREGO_NENHUM);
        dini_FloatSet(path, "Pos_X", 1958.3783);
        dini_FloatSet(path, "Pos_Y", 1343.1572);
        dini_FloatSet(path, "Pos_Z", 15.3746);
        
        Logado[playerid] = true;
        SpawnPlayer(playerid);
        return 1;
    }

    // Lógica de Login
    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        if(strcmp(inputtext, dini_Get(path, "Senha"), false) == 0) {
            PlayerEmprego[playerid] = dini_Int(path, "Emprego");
            Logado[playerid] = true;
            SpawnPlayer(playerid);
        } else {
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Erro", "Senha incorreta!", "Entrar", "Sair");
        }
        return 1;
    }

    // MENU PRINCIPAL DO GPS
    if(dialogid == DIALOG_GPS_MENU) {
        if(!response) return 1;
        if(listitem == 0) ShowPlayerDialog(playerid, DIALOG_GPS_LS, DIALOG_STYLE_LIST, "GPS - Los Santos", "Prefeitura\nBanco\nDP\nHospital\nAeroporto", "Marcar", "Voltar");
        if(listitem == 1) ShowPlayerDialog(playerid, DIALOG_GPS_SF, DIALOG_STYLE_LIST, "GPS - San Fierro", "Banco SF\nDP SF\nHospital SF\nAeroporto SF", "Marcar", "Voltar");
        if(listitem == 2) ShowPlayerDialog(playerid, DIALOG_GPS_LV, DIALOG_STYLE_LIST, "GPS - Las Venturas", "Cassino\nBanco LV\nDP LV\nAeroporto LV", "Marcar", "Voltar");
        if(listitem == 3) { DisablePlayerCheckpoint(playerid); SendClientMessage(playerid, -1, "GPS Desativado."); }
        return 1;
    }

    // SUB-MENUS GPS (LS, SF, LV)
    if(dialogid == DIALOG_GPS_LS || dialogid == DIALOG_GPS_SF || dialogid == DIALOG_GPS_LV) {
        if(!response) return cmd_gps(playerid, ""); // Se clicar em voltar, reabre o menu GPS
        DisablePlayerCheckpoint(playerid);
        
        if(dialogid == DIALOG_GPS_LS) {
            switch(listitem) {
                case 0: SetPlayerCheckpoint(playerid, 1481.0, -1741.0, 13.5, 4.0);
                case 1: SetPlayerCheckpoint(playerid, 1467.0, -1010.0, 26.0, 4.0);
                case 2: SetPlayerCheckpoint(playerid, 1543.0, -1675.0, 13.5, 4.0);
                case 3: SetPlayerCheckpoint(playerid, 1172.0, -1323.0, 14.0, 4.0);
                case 4: SetPlayerCheckpoint(playerid, 1958.0, -2173.0, 13.5, 4.0);
            }
        }
        else if(dialogid == DIALOG_GPS_SF) {
            switch(listitem) {
                case 0: SetPlayerCheckpoint(playerid, -2416.0, 508.0, 35.0, 4.0);
                case 1: SetPlayerCheckpoint(playerid, -1605.0, 711.0, 13.0, 4.0);
                case 2: SetPlayerCheckpoint(playerid, -2646.0, 630.0, 14.0, 4.0);
                case 3: SetPlayerCheckpoint(playerid, -1420.0, -287.0, 14.0, 4.0);
            }
        }
        else if(dialogid == DIALOG_GPS_LV) {
            switch(listitem) {
                case 0: SetPlayerCheckpoint(playerid, 2191.0, 1677.0, 12.0, 4.0);
                case 1: SetPlayerCheckpoint(playerid, 2372.0, 2311.0, 10.0, 4.0);
                case 2: SetPlayerCheckpoint(playerid, 2290.0, 2431.0, 10.0, 4.0);
                case 3: SetPlayerCheckpoint(playerid, 1585.0, 1445.0, 10.0, 4.0);
            }
        }
        SendClientMessage(playerid, 0xFFFF00FF, "GPS: Local marcado com sucesso!");
        return 1;
    }
    return 0;
}

public OnPlayerDisconnect(playerid, reason) {
    if(Logado[playerid]) {
        new path[64], Float:x, Float:y, Float:z;
        ContaPath(playerid, path, sizeof(path));
        GetPlayerPos(playerid, x, y, z);
        dini_IntSet(path, "Emprego", PlayerEmprego[playerid]);
        dini_FloatSet(path, "Pos_X", x);
        dini_FloatSet(path, "Pos_Y", y);
        dini_FloatSet(path, "Pos_Z", z);
    }
    Logado[playerid] = false;
    return 1;
}

public OnPlayerSpawn(playerid) {
    if(!Logado[playerid]) return Kick(playerid);
    
    new path[64];
    ContaPath(playerid, path, sizeof(path));
    if(dini_Exists(path)) {
        new Float:x = dini_Float(path, "Pos_X");
        new Float:y = dini_Float(path, "Pos_Y");
        new Float:z = dini_Float(path, "Pos_Z");
        if(x != 0.0) SetPlayerPos(playerid, x, y, z);
    }
    SetPlayerInterior(playerid, 0);
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    DisablePlayerCheckpoint(playerid);
    SendClientMessage(playerid, -1, "Você chegou ao seu destino!");
    return 1;
}

// Caso o comando /gps não esteja no seu commands.inc, ele está aqui:
CMD:gps(playerid, params[]) {
    if(!Logado[playerid]) return 1;
    new lista[128];
    format(lista, sizeof(lista), "Los Santos (LS)\nSan Fierro (SF)\nLas Venturas (LV)\n{FF0000}Desativar GPS");
    ShowPlayerDialog(playerid, DIALOG_GPS_MENU, DIALOG_STYLE_LIST, "GPS", lista, "Selecionar", "Sair");
    return 1;
}
