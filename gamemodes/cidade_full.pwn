/* 
    CIDADE FULL 2026 - VERSÃO ESTÁVEL
    Correção: Spawn na calçada e física da bike elétrica.
*/

#include <a_samp>
#include <zcmd>
#include <dini>

main() 
{ 
    print("---------------------------------------");
    print("   CIDADE FULL 2026 - ONLINE           ");
    print("---------------------------------------");
}

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
    SetGameModeText("Cidade Full v4.2");
    
    // Pickup na Calçada (Afastado do spawn para não bugar)
    PickupBike = CreatePickup(1239, 1, 1642.50, -2244.60, 13.50, -1);
    Create3DTextLabel("{00CCFF}ECO-BIKE\n{FFFFFF}Pise para pegar", 0xFFFFFFFF, 1642.50, -2244.60, 14.0, 10.0, 0, 0);
    
    AddPlayerClass(SKIN_NOVATO, 1642.17, -2256.39, 13.49, 178.0, 0, 0, 0, 0, 0, 0);
    return 1;
}

public OnPlayerConnect(playerid) {
    Logado[playerid] = false;
    BikeNovato[playerid] = -1;
    SetTimerEx("MostrarLogin", 1000, false, "i", playerid);
    return 1;
}

public OnPlayerSpawn(playerid) {
    if(!Logado[playerid]) return Kick(playerid);
    
    // Spawn na calçada (longe da via de carros)
    SetPlayerPos(playerid, 1645.50, -2250.20, 13.50);
    SetPlayerFacingAngle(playerid, 180.0);
    SetCameraBehindPlayer(playerid);
    return 1;
}

// --- LOGICA DA BIKE COM FIX DE MOVIMENTO ---
public OnPlayerPickUpPickup(playerid, pickupid) {
    if(pickupid == PickupBike) {
        if(IsPlayerInAnyVehicle(playerid)) return 1;
        if(BikeNovato[playerid] != -1) DestroyVehicle(BikeNovato[playerid]);
        
        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
        
        // Criar a bike a 0.8 de altura (evita prender no chão)
        BikeNovato[playerid] = CreateVehicle(510, x, y, z + 0.8, a, 1, 1, -1);
        
        // Timer de 200ms para colocar o player (estabiliza a bike antes de montar)
        SetTimerEx("MontarNaBike", 200, false, "ii", playerid, BikeNovato[playerid]);
        
        SendClientMessage(playerid, 0x00CCFFFF, "[ECO] Bike ativada! Apenas segure o acelerador.");
    }
    return 1;
}

forward MontarNaBike(playerid, vehicleid);
public MontarNaBike(playerid, vehicleid) {
    PutPlayerInVehicle(playerid, vehicleid, 0);
}

public OnPlayerUpdate(playerid) {
    if(Logado[playerid] && IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleID(playerid) == BikeNovato[playerid]) {
        new keys, ud, lr;
        GetPlayerKeys(playerid, keys, ud, lr);
        
        if(ud == KEY_UP) { // Aceleração Elétrica
            new Float:vx, Float:vy, Float:vz, Float:a;
            GetVehicleVelocity(BikeNovato[playerid], vx, vy, vz);
            GetVehicleZAngle(BikeNovato[playerid], a);
            
            // Impulso para onde a bike aponta
            if(vx < 0.7 && vy < 0.7) {
                SetVehicleVelocity(BikeNovato[playerid], 
                    vx + (0.025 * floatsin(-a, degrees)), 
                    vy + (0.025 * floatcos(-a, degrees)), 
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
            SendClientMessage(playerid, 0xFF0000FF, "[ECO] Bike removida.");
        }
    }
    return 1;
}

// --- COMANDOS E DIALOGOS ---
CMD:gps(playerid, params[]) {
    new d; strcat(d, "Banco LS\nPrefeitura\nAgência de Empregos\nHospital\nDelegacia\nAeroporto");
    ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST, "GPS 2026", d, "Marcar", "Sair");
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == DIALOG_REGISTER) {
        if(!response) return Kick(playerid);
        dini_Create(GetConta(playerid));
        dini_Set(GetConta(playerid), "Senha", inputtext);
        dini_IntSet(GetConta(playerid), "Grana", 5000);
        Logado[playerid] = true;
        SpawnPlayer(playerid);
        return 1;
    }
    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        if(!strcmp(inputtext, dini_Get(GetConta(playerid), "Senha"))) {
            Logado[playerid] = true;
            GivePlayerMoney(playerid, dini_Int(GetConta(playerid), "Grana"));
            SpawnPlayer(playerid);
        } else MostrarLogin(playerid);
        return 1;
    }
    if(dialogid == DIALOG_GPS && response) {
        new Float:X, Float:Y, Float:Z;
        switch(listitem) {
            case 0: { X = 1467.0; Y = -1010.0; Z = 26.0; }
            case 1: { X = 1481.0; Y = -1741.0; Z = 13.0; }
            case 2: { X = 1154.0; Y = -1770.0; Z = 13.0; }
            case 3: { X = 1172.3; Y = -1341.3; Z = 13.5; }
            case 4: { X = 1543.0; Y = -1675.0; Z = 13.5; }
            case 5: { X = 1642.17; Y = -2256.39; Z = 13.49; }
        }
        SetPlayerCheckpoint(playerid, X, Y, Z, 4.0);
        SendClientMessage(playerid, 0x00FF00FF, "Destino marcado!");
        return 1;
    }
    return 0;
}

public OnPlayerEnterCheckpoint(playerid) {
    DisablePlayerCheckpoint(playerid);
    SendClientMessage(playerid, 0xFFFF00FF, "Você chegou!");
    return 1;
}
