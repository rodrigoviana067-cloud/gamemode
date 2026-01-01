/* 
    CIDADE FULL 2026 - VERSÃO FINAL ECO-BIKE
    Aceleração automática e spawn sincronizado.
*/

#include <a_samp>
#include <zcmd>
#include <dini>

#define DIALOG_LOGIN        1
#define DIALOG_REGISTER     2
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
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{00CCFF}Login 2026", "Digite sua senha:", "Entrar", "Sair");
    } else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{00CCFF}Registro 2026", "Crie sua senha:", "Registrar", "Sair");
    }
}

public OnGameModeInit() {
    SetGameModeText("Cidade Full v3.5");
    // Pickup exatamente onde o jogador spawna
    PickupBike = CreatePickup(1239, 1, 1642.17, -2256.39, 13.49, -1);
    Create3DTextLabel("{00CCFF}BIKE ELÉTRICA\n{FFFFFF}Aceleração Automática", 0xFFFFFFFF, 1642.17, -2256.39, 14.0, 10.0, 0, 0);
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
    SetPlayerInterior(playerid, 0);
    return 1;
}

// --- LOGICA DA BIKE NO LOCAL DO PLAYER ---
public OnPlayerPickUpPickup(playerid, pickupid) {
    if(pickupid == PickupBike) {
        if(IsPlayerInAnyVehicle(playerid)) return 1;
        
        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
        
        // Criar a bike exatamente na posição e ângulo do player
        BikeNovato[playerid] = CreateVehicle(510, x, y, z, a, 1, 1, -1);
        PutPlayerInVehicle(playerid, BikeNovato[playerid], 0);
        
        SendClientMessage(playerid, 0x00CCFFFF, "[ECO] Bike Elétrica ativada! Basta segurar o acelerador.");
    }
    return 1;
}

// --- SISTEMA DE ACELERAÇÃO PELO BOTÃO (SEM W REPETIDO) ---
public OnPlayerUpdate(playerid) {
    if(IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleID(playerid) == BikeNovato[playerid]) {
        new keys, ud, lr;
        GetPlayerKeys(playerid, keys, ud, lr);
        
        // Se estiver segurando para frente (Acelerador padrão)
        if(ud == KEY_UP) {
            new Float:vx, Float:vy, Float:vz;
            GetVehicleVelocity(BikeNovato[playerid], vx, vy, vz);
            
            // Se estiver abaixo de uma velocidade razoável, dá o empurrão
            if(vx < 0.6 && vy < 0.6) {
                SetVehicleVelocity(BikeNovato[playerid], vx * 1.1, vy * 1.1, vz);
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
            SendClientMessage(playerid, 0xFF0000FF, "Bike removida.");
        }
    }
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == DIALOG_REGISTER || dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        
        if(dialogid == DIALOG_REGISTER) {
            if(strlen(inputtext) < 4) return MostrarLogin(playerid);
            dini_Create(GetConta(playerid));
            dini_Set(GetConta(playerid), "Senha", inputtext);
        } else {
            if(strcmp(inputtext, dini_Get(GetConta(playerid), "Senha"))) return MostrarLogin(playerid);
        }
        
        Logado[playerid] = true;
        // Trava o spawn no aeroporto
        SetSpawnInfo(playerid, 0, SKIN_NOVATO, 1642.17, -2256.39, 13.49, 178.0, 0, 0, 0, 0, 0, 0);
        SpawnPlayer(playerid);
        return 1;
    }
    return 0;
}
