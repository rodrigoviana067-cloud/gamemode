/* 
    CIDADE FULL 2026 - VERSÃO MASTER FINAL (100% ESTÁVEL)
    Sistemas: Login/Registro, GPS, Eco-Bike Elétrica e Salvamento de Grana.
*/

#include <a_samp>
#include <zcmd>
#include <dini>

// Ponto de entrada obrigatório para GameModes
main() 
{ 
    print("---------------------------------------");
    print("   CIDADE FULL 2026 - ONLINE           ");
    print("---------------------------------------");
}

// Configurações e IDs
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
    SetGameModeText("Cidade Full v4.5");
    
    // Pickup na Calçada (Afastado do spawn para não bugar a bike)
    PickupBike = CreatePickup(1239, 1, 1642.50, -2244.60, 13.50, -1);
    Create3DTextLabel("{00CCFF}ECO-BIKE\n{FFFFFF}Pise para pegar", 0xFFFFFFFF, 1642.50, -2244.60, 14.0, 10.0, 0, 0);
    
    // Classe padrão para evitar o CJ
    AddPlayerClass(SKIN_NOVATO, 1645.50, -2250.20, 13.50, 180.0, 0, 0, 0, 0, 0, 0);
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
        new path[64]; 
        format(path, sizeof(path), GetConta(playerid));
        dini_IntSet(path, "Grana", GetPlayerMoney(playerid)); 
    }
    if(BikeNovato[playerid] != -1) DestroyVehicle(BikeNovato[playerid]);
    return 1;
}

public OnPlayerSpawn(playerid) {
    if(!Logado[playerid]) return Kick(playerid);
    
    // Nascer na calçada do Aeroporto
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
        
        // Timer para estabilizar a física antes de montar
        SetTimerEx("MontarNaBike", 200, false, "ii", playerid, BikeNovato[playerid]);
        
        SendClientMessage(playerid, 0x00CCFFFF, "[ECO] Bike ativada! Basta segurar o acelerador (W).");
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
        
        if(ud == KEY_UP) { // Aceleração Elétrica Vetorial
            new Float:vx, Float:vy, Float:vz, Float:a;
            GetVehicleVelocity(BikeNovato[playerid], vx, vy, vz);
            GetVehicleZAngle(BikeNovato[playerid], a);
            
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
            SendClientMessage(playerid, 0xFF0000FF, "[ECO] Bike removida automaticamente.");
        }
    }
    return 1;
}

// --- COMANDOS ---
CMD:gps(playerid, params[]) {
    new d[256]; // String com tamanho definido para evitar erro 035
    strcat(d, "Banco LS\nPrefeitura\nAgência de Empregos\nHospital\nDelegacia\nAeroporto");
    ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST, "{00CCFF}GPS 2026", d, "Marcar", "Sair");
    return 1;
}

// --- RESPOSTAS DE DIÁLOGOS ---
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
        
        SetSpawnInfo(playerid, 0, SKIN_NOVATO, 1645.50, -2250.20, 13.50, 180.0, 0, 0, 0, 0, 0, 0);
        SpawnPlayer(playerid);
        return 1;
    }
    
    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        
        if(!strcmp(inputtext, dini_Get(path, "Senha"))) {
            Logado[playerid] = true;
            GivePlayerMoney(playerid, dini_Int(path, "Grana"));
            
            SetSpawnInfo(playerid, 0, SKIN_NOVATO, 1645.50, -2250.20, 13.50, 180.0, 0, 0, 0, 0, 0, 0);
            SpawnPlayer(playerid);
        } else {
            SendClientMessage(playerid, 0xFF0000FF, "Senha incorreta!");
            MostrarLogin(playerid);
        }
        return 1;
    }
    
    if(dialogid == DIALOG_GPS && response) {
        new Float:gX, Float:gY, Float:gZ;
        switch(listitem) {
            case 0: { gX = 1467.0; gY = -1010.0; gZ = 26.0; }
            case 1: { gX = 1481.0; gY = -1741.0; gZ = 13.0; }
            case 2: { gX = 1154.0; gY = -1770.0; gZ = 13.0; }
            case 3: { gX = 1172.3; gY = -1341.3; gZ = 13.5; }
            case 4: { gX = 1543.0; gY = -1675.0; gZ = 13.5; }
            case 5: { gX = 1642.17; gY = -2256.39; gZ = 13.49; }
        }
        SetPlayerCheckpoint(playerid, gX, gY, gZ, 4.0);
        SendClientMessage(playerid, 0x00FF00FF, "[GPS] Destino marcado!");
        return 1;
    }
    return 0;
}

public OnPlayerEnterCheckpoint(playerid) {
    DisablePlayerCheckpoint(playerid);
    SendClientMessage(playerid, 0xFFFF00FF, "Você chegou ao seu destino!");
    return 1;
}
