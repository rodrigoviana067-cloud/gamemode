#define FILTERSCRIPT
#include <a_samp>
#include <dini>

// --- ECONOMIA 2026 ---
#define PRECO_MOTO      3000
#define PRECO_CARRO     7000
#define PRECO_CAMINHAO  15000

#define VEH_MOTO        461 
#define VEH_CARRO       405 
#define VEH_CAMINHAO    403 

// --- COORDENADAS ---
#define AUTO_EXT_X 1412.0202
#define AUTO_EXT_Y -1699.9926
#define AUTO_EXT_Z 13.5394

// INTERIOR REAL DA AUTOESCOLA (ID 3)
#define AUTO_INT_X 2046.0
#define AUTO_INT_Y 155.0
#define AUTO_INT_Z 1060.98
#define AUTO_INT_ID 3
#define AUTO_VW     10 

#define AUTO_BALCAO_X 2043.0
#define AUTO_BALCAO_Y 162.0
#define AUTO_BALCAO_Z 1060.98

#define SPAWN_V_X 1400.0
#define SPAWN_V_Y -1670.0
#define SPAWN_V_Z 13.5
#define SPAWN_V_A 90.0

new EmTeste[MAX_PLAYERS], VeiculoTeste[MAX_PLAYERS], CategoriaTeste[MAX_PLAYERS], CheckStep[MAX_PLAYERS];
new ChaoSeguranca[MAX_PLAYERS]; // Variável para o chão virtual

// Corrigido para compilar 100%
stock CNHFile(playerid) {
    new name[MAX_PLAYER_NAME], path[128];
    GetPlayerName(playerid, name, sizeof(name));
    format(path, sizeof(path), "licencas/%s.ini", name);
    return path;
}

forward LiberarPlayer(playerid);
public LiberarPlayer(playerid) {
    TogglePlayerControllable(playerid, true);
    SetCameraBehindPlayer(playerid);
    
    // Deleta o chão virtual após o carregamento do mapa real
    if(ChaoSeguranca[playerid] != 0) {
        DestroyPlayerObject(playerid, ChaoSeguranca[playerid]);
        ChaoSeguranca[playerid] = 0;
    }
    return 1;
}

public OnFilterScriptInit() {
    DisableInteriorEnterExits();

    CreatePickup(1318, 1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z, 0); 
    Create3DTextLabel("{00CCFF}Autoescola\n{FFFFFF}Pressione 'H' para entrar", -1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z + 0.5, 10.0, 0);

    CreatePickup(1318, 1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z, AUTO_VW);
    Create3DTextLabel("{FFFFFF}Sair\n{777777}Pressione 'H'", -1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z + 0.5, 10.0, AUTO_VW);

    CreatePickup(1239, 1, AUTO_BALCAO_X, AUTO_BALCAO_Y, AUTO_BALCAO_Z, AUTO_VW);
    Create3DTextLabel("{00FF00}Atendimento\n{FFFFFF}Use /exame", -1, AUTO_BALCAO_X, AUTO_BALCAO_Y, AUTO_BALCAO_Z + 0.5, 8.0, AUTO_VW);
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { 
        // ENTRAR
        if(IsPlayerInRangeOfPoint(playerid, 2.5, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z)) {
            TogglePlayerControllable(playerid, false);
            
            // CRIA O CHÃO VIRTUAL (Objeto de colisão invisível)
            ChaoSeguranca[playerid] = CreatePlayerObject(playerid, 19129, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z - 1.0, 0.0, 0.0, 0.0);
            
            SetPlayerInterior(playerid, AUTO_INT_ID);
            SetPlayerVirtualWorld(playerid, AUTO_VW);
            SetPlayerPos(playerid, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z);
            
            SetTimerEx("LiberarPlayer", 4000, false, "i", playerid); // 4 segundos para garantir
            GameTextForPlayer(playerid, "~w~Carregando...", 3000, 3);
            return 1;
        }
        // SAIR
        if(IsPlayerInRangeOfPoint(playerid, 2.5, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z)) {
            TogglePlayerControllable(playerid, false);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
            SetPlayerPos(playerid, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z);
            SetTimerEx("LiberarPlayer", 1500, false, "i", playerid);
            return 1;
        }
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(!strcmp(cmdtext, "/exame", true)) {
        if(!IsPlayerInRangeOfPoint(playerid, 4.0, AUTO_BALCAO_X, AUTO_BALCAO_Y, AUTO_BALCAO_Z))
            return SendClientMessage(playerid, -1, "Vá até o balcão!");

        ShowPlayerDialog(playerid, 9955, DIALOG_STYLE_LIST, "Autoescola", "Moto\nCarro\nCaminhao", "Iniciar", "Sair");
        return 1;
    }
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == 9955 && response) {
        new preco, veh;
        if(listitem == 0) { preco = PRECO_MOTO; veh = VEH_MOTO; CategoriaTeste[playerid] = 1; }
        else if(listitem == 1) { preco = PRECO_CARRO; veh = VEH_CARRO; CategoriaTeste[playerid] = 2; }
        else { preco = PRECO_CAMINHAO; veh = VEH_CAMINHAO; CategoriaTeste[playerid] = 3; }

        if(GetPlayerMoney(playerid) < preco) return SendClientMessage(playerid, -1, "Sem dinheiro!");
        
        GivePlayerMoney(playerid, -preco);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z + 0.5);
        
        EmTeste[playerid] = 1; 
        VeiculoTeste[playerid] = CreateVehicle(veh, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z, SPAWN_V_A, 1, 1, 120);
        
        SetTimerEx("IniciaVeh", 1500, false, "ii", playerid, VeiculoTeste[playerid]);
        return 1;
    }
    return 1;
}

forward IniciaVeh(playerid, v);
public IniciaVeh(playerid, v) {
    PutPlayerInVehicle(playerid, v, 0);
    SetPlayerCheckpoint(playerid, 1340.0, -1660.0, 13.5, 5.0);
    SendClientMessage(playerid, 0xFFFF00FF, "Teste iniciado!");
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    if(EmTeste[playerid]) {
        CheckStep[playerid]++;
        if(CheckStep[playerid] == 1) SetPlayerCheckpoint(playerid, 1450.0, -1750.0, 13.5, 5.0);
        else FinalizarTeste(playerid, true);
    }
    return 1;
}

stock FinalizarTeste(playerid, bool:aprovado) {
    DisablePlayerCheckpoint(playerid);
    if(VeiculoTeste[playerid] != -1) DestroyVehicle(VeiculoTeste[playerid]);
    VeiculoTeste[playerid] = -1;
    EmTeste[playerid] = 0;
    if(aprovado) {
        new path[128]; format(path, sizeof(path), "%s", CNHFile(playerid));
        if(!dini_Exists(path)) dini_Create(path);
        dini_IntSet(path, "Habilitado", 1);
        SendClientMessage(playerid, 0x00FF00FF, "Aprovado!");
    }
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
    if(EmTeste[playerid] && vehicleid == VeiculoTeste[playerid]) FinalizarTeste(playerid, false);
    return 1;
}
