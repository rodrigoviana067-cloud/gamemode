/* 
    CIDADE FULL 2026 - VERSÃO MASTER
    Sistemas: Login/Registro, GPS, Eco-Bike e Salvamento.
*/

#include <a_samp>
#include <zcmd>
#include <dini>

#define DIALOG_LOGIN        1
#define DIALOG_REGISTER     2
#define DIALOG_GPS          3
#define SKIN_NOVATO         26

new bool:Logado[MAX_PLAYERS];
new BikeNovato[MAX_PLAYERS];
new PickupBike;

// --- Funções de Conta ---
stock GetConta(playerid) {
    new str[64], name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), "contas/%s.ini", name);
    return str;
}

forward MostrarLogin(playerid);
public MostrarLogin(playerid) {
    if (dini_Exists(GetConta(playerid))) {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{00CCFF}Login 2026", "Digite sua senha para entrar:", "Entrar", "Sair");
    } else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{00CCFF}Registro 2026", "Crie uma senha para sua conta:", "Registrar", "Sair");
    }
}

public OnGameModeInit() {
    SetGameModeText("Cidade Full v4.0");
    
    // Pickup exatamente onde o jogador spawna (Saída do Aeroporto)
    PickupBike = CreatePickup(1239, 1, 1642.17, -2256.39, 13.49, -1);
    Create3DTextLabel("{00CCFF}BIKE ELÉTRICA\n{FFFFFF}Aceleração Automática", 0xFFFFFFFF, 1642.17, -2256.39, 14.0, 10.0, 0, 0);
    
    // Adiciona classe para evitar bug de spawn
    AddPlayerClass(SKIN_NOVATO, 1642.17, -2256.39, 13.49, 178.0, 0, 0, 0, 0, 0, 0);
    return 1;
}

public OnPlayerConnect(playerid) {
    Logado[playerid] = false;
    BikeNovato[playerid] = -1;
    SetTimerEx("MostrarLogin", 1000, false, "i", playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    if(Logado[playerid]) {
        new path[64]; format(path, sizeof(path), GetConta(playerid));
        dini_IntSet(path, "Grana", GetPlayerMoney(playerid)); // Salva o dinheiro ao sair
    }
    if(BikeNovato[playerid] != -1) DestroyVehicle(BikeNovato[playerid]);
    return 1;
}

public OnPlayerSpawn(playerid) {
    if(!Logado[playerid]) return Kick(playerid);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    return 1;
}

// --- LOGICA DA BIKE ELÉTRICA ---
public OnPlayerPickUpPickup(playerid, pickupid) {
    if(pickupid == PickupBike) {
        if(IsPlayerInAnyVehicle(playerid)) return 1;
        
        if(BikeNovato[playerid] != -1) DestroyVehicle(BikeNovato[playerid]);
        
        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
        
        // Criar a bike levemente acima do chão (z + 0.5) para não bugar
        BikeNovato[playerid] = CreateVehicle(510, x, y, z + 0.5, a, 1, 1, -1);
        PutPlayerInVehicle(playerid, BikeNovato[playerid], 0);
        
        SendClientMessage(playerid, 0x00CCFFFF, "[ECO] Bike Elétrica ativada! Apenas segure o acelerador.");
    }
    return 1;
}

public OnPlayerUpdate(playerid) {
    if(Logado[playerid] && IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleID(playerid) == BikeNovato[playerid]) {
        new keys, ud, lr;
        GetPlayerKeys(playerid, keys, ud, lr);
        
        if(ud == KEY_UP) { // Aceleração automática
            new Float:vx, Float:vy, Float:vz, Float:a;
            GetVehicleVelocity(BikeNovato[playerid], vx, vy, vz);
            GetVehicleZAngle(BikeNovato[playerid], a);
            
            if(vx < 0.7 && vy < 0.7) {
                SetVehicleVelocity(BikeNovato[playerid], 
                    vx + (0.02 * floatsin(-a, degrees)), 
                    vy + (0.02 * floatcos(-a, degrees)), 
                    vz);
            }
        }
    }
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate) {
    if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT) {
        if(BikeNovato[playerid] != -1) {
            DestroyVehicle(BikeNovato[playerid]);
            BikeNovato[playerid] = -1;
            SendClientMessage(playerid, 0xFF0000FF, "[ECO] Bike removida automaticamente.");
        }
    }
    return 1;
}

// --- COMANDO GPS INTEGRADO ---
CMD:gps(playerid, params[]) {
    new destinos[300];
    strcat(destinos, "Banco LS\nPrefeitura\nAgência de Empregos\nHospital Central\nDelegacia de Polícia\nAeroporto (Spawn)");
    ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST, "{00CCFF}GPS Cidade Full", destinos, "Marcar", "Fechar");
    return 1;
}

// --- RESPOSTAS DE DIÁLOGOS ---
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == DIALOG_REGISTER || dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        
        if(dialogid == DIALOG_REGISTER) {
            if(strlen(inputtext) < 4) return MostrarLogin(playerid);
            dini_Create(GetConta(playerid));
            dini_Set(GetConta(playerid), "Senha", inputtext);
            dini_IntSet(GetConta(playerid), "Grana", 5000); // Grana inicial
        } else {
            if(strcmp(inputtext, dini_Get(GetConta(playerid), "Senha"))) return MostrarLogin(playerid);
            GivePlayerMoney(playerid, dini_Int(GetConta(playerid), "Grana")); // Carrega grana
        }
        
        Logado[playerid] = true;
        SetSpawnInfo(playerid, 0, SKIN_NOVATO, 1642.17, -2256.39, 13.49, 178.0, 0, 0, 0, 0, 0, 0);
        SpawnPlayer(playerid);
        return 1;
    }

    if(dialogid == DIALOG_GPS && response) {
        new Float:X, Float:Y, Float:Z, local[32];
        switch(listitem) {
            case 0: { X = 1467.0; Y = -1010.0; Z = 26.0; local = "Banco LS"; }
            case 1: { X = 1481.0; Y = -1741.0; Z = 13.0; local = "Prefeitura"; }
            case 2: { X = 1154.0; Y = -1770.0; Z = 13.0; local = "Agência de Empregos"; }
            case 3: { X = 1172.3; Y = -1341.3; Z = 13.5; local = "Hospital Central"; }
            case 4: { X = 1543.0; Y = -1675.0; Z = 13.5; local = "Delegacia"; }
            case 5: { X = 1642.17; Y = -2256.39; Z = 13.49; local = "Aeroporto"; }
        }
        SetPlayerCheckpoint(playerid, X, Y, Z, 4.0);
        new msg[64]; format(msg, sizeof(msg), "{00FF00}[GPS] Destino marcado: %s", local);
        SendClientMessage(playerid, -1, msg);
        return 1;
    }
    return 0;
}

public OnPlayerEnterCheckpoint(playerid) {
    DisablePlayerCheckpoint(playerid);
    SendClientMessage(playerid, 0xFFFF00FF, "[GPS] Você chegou ao destino!");
    return 1;
}
