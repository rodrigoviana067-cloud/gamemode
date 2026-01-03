/* 
    CIDADE FULL 2026 - VERSÃO MASTER FINAL (MODULARIZADA)
    Spawn Atualizado: LS Aeroporto (Coordenadas Customizadas)
*/

#include <a_samp>
#include <zcmd>
#include <dini>

main() 
{ 
    print("---------------------------------------");
    print("   CIDADE FULL 2026 - GAME LOADED      ");
    print("---------------------------------------");
}

// IDs Altos para não conflitar com Filterscripts
#define DIALOG_LOGIN        2000
#define DIALOG_REGISTER     2001
#define SKIN_NOVATO         26

// NOVAS COORDENADAS DE SPAWN (LS)
#define SPAWN_X 1642.8808
#define SPAWN_Y -2239.0747
#define SPAWN_Z 13.4961
#define SPAWN_A 177.5711

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
    SetGameModeText("Cidade Full v4.5");
    
    // Pickup ECO-BIKE (Mantido próximo ao spawn)
    PickupBike = CreatePickup(1239, 1, 1642.50, -2244.60, 13.50, -1);
    Create3DTextLabel("{00CCFF}ECO-BIKE\n{FFFFFF}Pise para pegar", 0xFFFFFFFF, 1642.50, -2244.60, 14.0, 10.0, 0, 0);
    
    // Classe padrão (usada na seleção de personagens se necessário)
    AddPlayerClass(SKIN_NOVATO, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 0, 0, 0, 0, 0, 0);
    return 1;
}

public OnPlayerConnect(playerid) {
    Logado[playerid] = false;
    BikeNovato[playerid] = -1;
    SetTimerEx("MostrarLogin", 1500, false, "i", playerid); 
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    if(Logado[playerid]) {
        new path[64]; 
        format(path, sizeof(path), GetConta(playerid));
        dini_IntSet(path, "Grana", GetPlayerMoney(playerid)); 
    }
    if(BikeNovato[playerid] != -1) DestroyVehicle(BikeNovato[playerid]);
    return 1;
}

public OnPlayerSpawn(playerid) {
    if(!Logado[playerid]) return Kick(playerid);
    
    // Aplicando o novo Spawn
    SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
    SetPlayerFacingAngle(playerid, SPAWN_A);
    
    SetCameraBehindPlayer(playerid);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid) {
    if(pickupid == PickupBike) {
        if(IsPlayerInAnyVehicle(playerid)) return 1;
        if(BikeNovato[playerid] != -1) DestroyVehicle(BikeNovato[playerid]);
        
        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
        
        BikeNovato[playerid] = CreateVehicle(510, x, y, z + 0.8, a, 1, 1, -1);
        SetTimerEx("MontarNaBike", 250, false, "ii", playerid, BikeNovato[playerid]);
        SendClientMessage(playerid, 0x00CCFFFF, "[ECO] Bike Elétrica ativada!");
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
        if(ud == KEY_UP) { 
            new Float:vx, Float:vy, Float:vz, Float:a;
            GetVehicleVelocity(BikeNovato[playerid], vx, vy, vz);
            GetVehicleZAngle(BikeNovato[playerid], a);
            if(vx < 0.7 && vy < 0.7) {
                SetVehicleVelocity(BikeNovato[playerid], vx + (0.025 * floatsin(-a, degrees)), vy + (0.025 * floatcos(-a, degrees)), vz);
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

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    new path[64];
    format(path, sizeof(path), GetConta(playerid));

    if(dialogid == DIALOG_REGISTER) {
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 4) return MostrarLogin(playerid);
        dini_Create(path);
        dini_Set(path, "Senha", inputtext);
        dini_IntSet(path, "Grana", 5000);
        Logado[playerid] = true;
        
        // Atualizado com novas coordenadas
        SetSpawnInfo(playerid, 0, SKIN_NOVATO, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 0, 0, 0, 0, 0, 0);
        SpawnPlayer(playerid);
        return 1;
    }
    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        if(!strcmp(inputtext, dini_Get(path, "Senha"))) {
            Logado[playerid] = true;
            GivePlayerMoney(playerid, dini_Int(path, "Grana"));
            
            // Atualizado com novas coordenadas
            SetSpawnInfo(playerid, 0, SKIN_NOVATO, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 0, 0, 0, 0, 0, 0);
            SpawnPlayer(playerid);
        } else MostrarLogin(playerid);
        return 1;
    }
    return 0; 
}
