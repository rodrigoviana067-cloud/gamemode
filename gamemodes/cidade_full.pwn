/* 
    GAMEMODE: CIDADE FULL 2026 - VERSÃO ESTÁVEL
    Sistemas: Login/Registro (Dini), Spawn Realista, GPS e Bikes Anti-Poluição.
*/

#include <a_samp>
#include <zcmd>
#include <dini>

// Configurações e IDs
#define DIALOG_LOGIN        1
#define DIALOG_REGISTER     2
#define DIALOG_GUIA         3
#define DIALOG_GPS          4
#define SKIN_NOVATO         26

new bool:Logado[MAX_PLAYERS];
new BikeNovato[MAX_PLAYERS];
new PickupBike;

// --- Funções Auxiliares ---

stock GetConta(playerid) {
    new str[64], name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), "contas/%s.ini", name);
    return str;
}

forward MostrarLogin(playerid);
public MostrarLogin(playerid) {
    if (dini_Exists(GetConta(playerid))) {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{00CCFF}Login 2026", "Bem-vindo de volta!\nDigite sua senha:", "Entrar", "Sair");
    } else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{00CCFF}Registro 2026", "Você é novo aqui!\nCrie uma senha:", "Registrar", "Sair");
    }
}

forward MontarNaBike(playerid, vehicleid);
public MontarNaBike(playerid, vehicleid) {
    PutPlayerInVehicle(playerid, vehicleid, 0);
    return 1;
}

// --- Início do GameMode ---

main() { print(">> Cidade Full 2026: Sistema Iniciado."); }

public OnGameModeInit() {
    SetGameModeText("Cidade Full v2.5");
    AddPlayerClass(SKIN_NOVATO, 1642.17, -2256.39, 13.49, 178.0, 0, 0, 0, 0, 0, 0);
    
    // Pickup de Bike (ID 1239) na saída do desembarque
    PickupBike = CreatePickup(1239, 1, 1642.47, -2239.31, 13.49, -1);
    Create3DTextLabel("{FFFF00}BIKE DE NOVATO\n{FFFFFF}Pise para pegar", 0xFFFFFFFF, 1642.47, -2239.31, 14.0, 15.0, 0, 0);
    
    // Pickup Banco
    CreatePickup(1274, 1, 1467.0, -1010.0, 26.0, -1); 
    return 1;
}

public OnPlayerConnect(playerid) {
    Logado[playerid] = false;
    BikeNovato[playerid] = -1;
    RemoveBuildingForPlayer(playerid, 1, 0.0, 0.0, 0.0, 6000.0); // Limpeza de mapa opcional
    SetTimerEx("MostrarLogin", 1000, false, "i", playerid);
    return 1;
}

public OnPlayerSpawn(playerid) {
    if(!Logado[playerid]) return Kick(playerid);
    
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetCameraBehindPlayer(playerid);
    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid) {
    if(pickupid == PickupBike) {
        if(IsPlayerInAnyVehicle(playerid)) return 1;
        
        if(BikeNovato[playerid] != -1) DestroyVehicle(BikeNovato[playerid]);
        
        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
        
        // ID 510 (Mountain Bike) criada levemente acima para não travar no chão
        BikeNovato[playerid] = CreateVehicle(510, x, y, z + 0.6, a, 1, 1, -1);
        
        // Delay de 200ms para a física carregar antes de montar
        SetTimerEx("MontarNaBike", 200, false, "ii", playerid, BikeNovato[playerid]);
        
        SendClientMessage(playerid, 0xFFFF00FF, "[INFO] Bike entregue! Aperte 'W' repetidamente para pedalar.");
    }
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate) {
    if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT) {
        if(BikeNovato[playerid] != -1) {
            DestroyVehicle(BikeNovato[playerid]);
            BikeNovato[playerid] = -1;
            SendClientMessage(playerid, 0xFF0000FF, "[!] Bike removida para evitar poluição.");
        }
    }
    return 1;
}

// --- COMANDOS ZCMD ---

CMD:gps(playerid, params[]) {
    ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST, "{00CCFF}GPS Cidade Full", "Banco LS\nPrefeitura\nAgência de Empregos\nAeroporto (Spawn)", "Marcar", "Fechar");
    return 1;
}

CMD:guia(playerid, params[]) {
    new str[400];
    strcat(str, "{FFFF00}--- GUIA 2026 ---\n\n");
    strcat(str, "{FFFFFF}- Pegue sua bike no ícone 'i' na saída.\n");
    strcat(str, "- Use /gps para se localizar.\n");
    strcat(str, "- A bike de novato some se você descer dela.\n");
    strcat(str, "- Bom divertimento no Cidade Full!");
    ShowPlayerDialog(playerid, DIALOG_GUIA, DIALOG_STYLE_MSGBOX, "Guia do Servidor", str, "Ok", "");
    return 1;
}

// --- Diálogos ---

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == DIALOG_REGISTER) {
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 4) return MostrarLogin(playerid);
        
        dini_Create(GetConta(playerid));
        dini_Set(GetConta(playerid), "Senha", inputtext);
        dini_IntSet(GetConta(playerid), "Grana", 5000);
        
        Logado[playerid] = true;
        SetSpawnInfo(playerid, 0, SKIN_NOVATO, 1642.17, -2256.39, 13.49, 178.0, 0, 0, 0, 0, 0, 0);
        SpawnPlayer(playerid);
        return 1;
    }
    
    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        if(!strcmp(inputtext, dini_Get(GetConta(playerid), "Senha"))) {
            GivePlayerMoney(playerid, dini_Int(GetConta(playerid), "Grana"));
            Logado[playerid] = true;
            SetSpawnInfo(playerid, 0, SKIN_NOVATO, 1642.17, -2256.39, 13.49, 178.0, 0, 0, 0, 0, 0, 0);
            SpawnPlayer(playerid);
        } else {
            SendClientMessage(playerid, 0xFF0000FF, "Senha incorreta!");
            MostrarLogin(playerid);
        }
        return 1;
    }

    if(dialogid == DIALOG_GPS && response) {
        switch(listitem) {
            case 0: SetPlayerCheckpoint(playerid, 1467.0, -1010.0, 26.0, 4.0);
            case 1: SetPlayerCheckpoint(playerid, 1481.0, -1741.0, 13.0, 4.0);
            case 2: SetPlayerCheckpoint(playerid, 1154.0, -1770.0, 13.0, 4.0);
            case 3: SetPlayerCheckpoint(playerid, 1642.17, -2256.39, 13.49, 4.0);
        }
        SendClientMessage(playerid, 0x00FF00FF, "[GPS] Local marcado no seu mapa!");
        return 1;
    }
    return 0;
}

public OnPlayerEnterCheckpoint(playerid) {
    DisablePlayerCheckpoint(playerid);
    SendClientMessage(playerid, 0xFFFF00FF, "[GPS] Você chegou ao seu destino!");
    return 1;
}
