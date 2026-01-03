#define FILTERSCRIPT
#include <a_samp>
#include <dini>
#include <float>

// --- CONFIGURAÇÕES ECONOMIA 2026 ---
#define PRECO_MOTO      3000
#define PRECO_CARRO     7000
#define PRECO_CAMINHAO  15000

#define VEH_MOTO        461 
#define VEH_CARRO       405 
#define VEH_CAMINHAO    403 

// --- COORDENADAS ---
// Calçada (Sua coordenada)
#define AUTO_EXT_X 1412.0202
#define AUTO_EXT_Y -1699.9926
#define AUTO_EXT_Z 13.5394

// INTERIOR ID 12 - Nascer longe da porta para evitar bugs
#define AUTO_INT_X -26.68  // Ponto de spawn (atrás do balcão)
#define AUTO_INT_Y -57.71
#define AUTO_INT_Z 1003.54
#define AUTO_INT_ID 12

// Balcão de Atendimento (Comando /exame)
#define AUTO_BALCAO_X -25.50
#define AUTO_BALCAO_Y -55.80
#define AUTO_BALCAO_Z 1003.54

// Pickup de Saída (Na porta do interior)
#define AUTO_SAIDA_X -27.80
#define AUTO_SAIDA_Y -51.50
#define AUTO_SAIDA_Z 1003.54

// Spawn do Veículo (Rua)
#define SPAWN_V_X 1400.0
#define SPAWN_V_Y -1670.0
#define SPAWN_V_Z 13.5
#define SPAWN_V_A 90.0

new EmTeste[MAX_PLAYERS], VeiculoTeste[MAX_PLAYERS], CategoriaTeste[MAX_PLAYERS], CheckStep[MAX_PLAYERS];

// Corrigido para compilar: String formatada
stock CNHFile(playerid) {
    new name[MAX_PLAYER_NAME], path[128];
    GetPlayerName(playerid, name, sizeof(name));
    format(path, sizeof(path), "licencas/%s.ini", name);
    return path;
}

forward DescongelarPlayer(playerid);
public DescongelarPlayer(playerid) {
    TogglePlayerControllable(playerid, true);
    SetCameraBehindPlayer(playerid);
    return 1;
}

public OnFilterScriptInit() {
    // Pickup na Rua
    CreatePickup(1318, 1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z, 0); 
    Create3DTextLabel("{FFFFFF}Autoescola\n{777777}Aperte 'H' para entrar", -1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z + 0.5, 15.0, 0);

    // Pickup de Saída dentro do interior
    CreatePickup(1318, 1, AUTO_SAIDA_X, AUTO_SAIDA_Y, AUTO_SAIDA_Z, 0);
    Create3DTextLabel("{FFFFFF}Sair\n{777777}Aperte 'H'", -1, AUTO_SAIDA_X, AUTO_SAIDA_Y, AUTO_SAIDA_Z + 0.5, 10.0, 0);

    // Balcão /exame
    CreatePickup(1239, 1, AUTO_BALCAO_X, AUTO_BALCAO_Y, AUTO_BALCAO_Z, 0);
    Create3DTextLabel("{00FF00}Atendimento\n{FFFFFF}Use /exame", -1, AUTO_BALCAO_X, AUTO_BALCAO_Y, AUTO_BALCAO_Z + 0.5, 8.0, 0);
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { 
        // Entrar (Vai para trás do balcão)
        if(IsPlayerInRangeOfPoint(playerid, 2.0, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z)) {
            TogglePlayerControllable(playerid, false);
            SetPlayerInterior(playerid, AUTO_INT_ID);
            SetPlayerPos(playerid, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z);
            SetTimerEx("DescongelarPlayer", 2000, false, "i", playerid);
        }
        // Sair (Usando o pickup da porta interna)
        else if(IsPlayerInRangeOfPoint(playerid, 2.0, AUTO_SAIDA_X, AUTO_SAIDA_Y, AUTO_SAIDA_Z)) {
            TogglePlayerControllable(playerid, false);
            SetPlayerInterior(playerid, 0);
            SetPlayerPos(playerid, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z);
            SetTimerEx("DescongelarPlayer", 1500, false, "i", playerid);
        }
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(!strcmp(cmdtext, "/exame", true)) {
        if(!IsPlayerInRangeOfPoint(playerid, 4.0, AUTO_BALCAO_X, AUTO_BALCAO_Y, AUTO_BALCAO_Z))
            return SendClientMessage(playerid, -1, "{FF0000}Va ate o balcao!");

        ShowPlayerDialog(playerid, 9955, DIALOG_STYLE_LIST, "{00CCFF}Autoescola", "Moto\nCarro\nCaminhao", "Iniciar", "Sair");
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

        if(GetPlayerMoney(playerid) < preco) return SendClientMessage(playerid, -1, "{FF0000}Sem dinheiro!");
        
        GivePlayerMoney(playerid, -preco);
        SetPlayerInterior(playerid, 0);
        SetPlayerPos(playerid, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z);
        
        EmTeste[playerid] = 1;
        CheckStep[playerid] = 0;
        VeiculoTeste[playerid] = CreateVehicle(veh, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z, SPAWN_V_A, 1, 1, 120);
        
        SetTimerEx("PutIn", 1000, false, "ii", playerid, VeiculoTeste[playerid]);
        SetPlayerCheckpoint(playerid, 1340.0, -1660.0, 13.5, 5.0);
    }
    return 1;
}

forward PutIn(playerid, v);
public PutIn(playerid, v) { PutPlayerInVehicle(playerid, v, 0); return 1; }

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
        new file_path[128]; // Corrigido para String
        format(file_path, sizeof(file_path), "%s", CNHFile(playerid));
        if(!dini_Exists(file_path)) dini_Create(file_path);
        
        if(CategoriaTeste[playerid] == 1) dini_IntSet(file_path, "Moto", 1);
        else if(CategoriaTeste[playerid] == 2) dini_IntSet(file_path, "Carro", 1);
        else if(CategoriaTeste[playerid] == 3) dini_IntSet(file_path, "Caminhao", 1);
        
        SendClientMessage(playerid, 0x00FF00FF, "Aprovado!");
    } else SendClientMessage(playerid, 0xFF0000FF, "Falhou!");
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
    if(EmTeste[playerid] && vehicleid == VeiculoTeste[playerid]) FinalizarTeste(playerid, false);
    return 1;
}
