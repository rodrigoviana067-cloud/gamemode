#define FILTERSCRIPT
#include <a_samp>
#include <dini>
#include <float>

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

#define AUTO_INT_X -26.68
#define AUTO_INT_Y -57.71
#define AUTO_INT_Z 1003.54
#define AUTO_INT_ID 12
#define AUTO_VW     500 

#define AUTO_BALCAO_X -25.50
#define AUTO_BALCAO_Y -55.80
#define AUTO_BALCAO_Z 1003.54

// Spawn do Veículo (Lugar seguro na rua)
#define SPAWN_V_X 1400.0
#define SPAWN_V_Y -1670.0
#define SPAWN_V_Z 13.5
#define SPAWN_V_A 90.0

new EmTeste[MAX_PLAYERS], VeiculoTeste[MAX_PLAYERS], CategoriaTeste[MAX_PLAYERS], CheckStep[MAX_PLAYERS];

stock CNHFile(playerid) {
    new name[MAX_PLAYER_NAME], path[64];
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
    DisableInteriorEnterExits();

    CreatePickup(1318, 1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z, 0); 
    Create3DTextLabel("{FFFFFF}Autoescola\n{777777}Aperte 'H' para entrar", -1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z + 0.5, 15.0, 0);

    CreatePickup(1318, 1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z, AUTO_VW);
    Create3DTextLabel("{FFFFFF}Sair\n{777777}Aperte 'H'", -1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z + 0.5, 10.0, AUTO_VW);

    CreatePickup(1239, 1, AUTO_BALCAO_X, AUTO_BALCAO_Y, AUTO_BALCAO_Z, AUTO_VW);
    Create3DTextLabel("{00FF00}Atendimento\n{FFFFFF}Use /exame", -1, AUTO_BALCAO_X, AUTO_BALCAO_Y, AUTO_BALCAO_Z + 0.5, 8.0, AUTO_VW);
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { 
        if(IsPlayerInRangeOfPoint(playerid, 2.5, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z)) {
            TogglePlayerControllable(playerid, false);
            SetPlayerInterior(playerid, AUTO_INT_ID);
            SetPlayerVirtualWorld(playerid, AUTO_VW);
            SetPlayerPos(playerid, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z);
            SetTimerEx("DescongelarPlayer", 2000, false, "i", playerid);
        }
        else if(IsPlayerInRangeOfPoint(playerid, 2.5, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z)) {
            TogglePlayerControllable(playerid, false);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
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

        ShowPlayerDialog(playerid, 9955, DIALOG_STYLE_LIST, "{00CCFF}Categorias", "Moto\nCarro\nCaminhao", "Iniciar", "Sair");
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

        if(GetPlayerMoney(playerid) < preco) return SendClientMessage(playerid, -1, "Dinheiro insuficiente!");
        
        GivePlayerMoney(playerid, -preco);
        
        // --- PROCESSO DE SAIDA PARA TESTE ---
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z + 1.0); // Spawna no ar pra não bugar
        TogglePlayerControllable(playerid, false); // Congela até o carro aparecer

        EmTeste[playerid] = 1; 
        CheckStep[playerid] = 0;
        
        // Cria o veículo
        VeiculoTeste[playerid] = CreateVehicle(veh, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z, SPAWN_V_A, 1, 1, 120);
        
        // Timer de segurança para colocar o player dentro do carro após ele sair do interior
        SetTimerEx("IniciarTesteTimer", 1500, false, "ii", playerid, VeiculoTeste[playerid]);
        
        SetPlayerCheckpoint(playerid, 1340.0, -1660.0, 13.5, 5.0);
        SendClientMessage(playerid, 0xFFFF00FF, "[AUTOESCOLA] Carregando veiculo de teste...");
    }
    return 1;
}

forward IniciarTesteTimer(playerid, veh);
public IniciarTesteTimer(playerid, veh) {
    if(!IsPlayerConnected(playerid)) return 1;
    
    PutPlayerInVehicle(playerid, veh, 0);
    TogglePlayerControllable(playerid, true);
    SetCameraBehindPlayer(playerid);
    SendClientMessage(playerid, 0x00FF00FF, "[AUTOESCOLA] Teste iniciado! Siga os checkpoints.");
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    if(EmTeste[playerid]) {
        CheckStep[playerid]++;
        if(CheckStep[playerid] == 1) SetPlayerCheckpoint(playerid, 1450.0, -1750.0, 13.5, 5.0);
        else if(CheckStep[playerid] == 2) SetPlayerCheckpoint(playerid, 1411.0, -1710.0, 13.5, 5.0);
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
        new path[64]; format(path, sizeof(path), "%s", CNHFile(playerid));
        if(!dini_Exists(path)) dini_Create(path);
        
        if(CategoriaTeste[playerid] == 1) dini_IntSet(path, "Moto", 1);
        else if(CategoriaTeste[playerid] == 2) dini_IntSet(path, "Carro", 1);
        else dini_IntSet(path, "Caminhao", 1);
        
        SendClientMessage(playerid, 0x00FF00FF, "Parabens! Voce foi aprovado.");
    } else {
        SendClientMessage(playerid, 0xFF0000FF, "Voce falhou no teste.");
    }
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
    if(EmTeste[playerid] && vehicleid == VeiculoTeste[playerid]) FinalizarTeste(playerid, false);
    return 1;
}
