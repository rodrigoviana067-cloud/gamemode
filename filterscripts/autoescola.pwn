#define FILTERSCRIPT
#include <a_samp>
#include <dini>

// --- CONFIGURAÇÕES ECONOMIA 2026 ---
#define PRECO_MOTO      3000
#define PRECO_CARRO     7000
#define PRECO_CAMINHAO  15000

#define VEH_MOTO        461 
#define VEH_CARRO       405 
#define VEH_CAMINHAO    403 

// --- COORDENADAS ---
// Entrada na calçada (conforme você passou)
#define AUTO_EXT_X 1412.0202
#define AUTO_EXT_Y -1699.9926
#define AUTO_EXT_Z 13.5394

// INTERIOR OFICIAL AUTOESCOLA (Coordenadas de corredor estável para não cair)
#define AUTO_INT_X 2045.5414
#define AUTO_INT_Y 154.2185
#define AUTO_INT_Z 1061.1110
#define AUTO_INT_ID 3

// Balcão de Atendimento (Dentro do interior)
#define AUTO_BALCAO_X 2043.9105
#define AUTO_BALCAO_Y 164.7176
#define AUTO_BALCAO_Z 1061.1110

// Spawn do Veículo (Rua)
#define SPAWN_V_X 1400.0
#define SPAWN_V_Y -1670.0
#define SPAWN_V_Z 13.5
#define SPAWN_V_A 90.0

new EmTeste[MAX_PLAYERS], VeiculoTeste[MAX_PLAYERS], CategoriaTeste[MAX_PLAYERS], CheckStep[MAX_PLAYERS];

stock CNHFile(playerid) {
    new name[MAX_PLAYER_NAME], str[64];
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), "licencas/%s.ini", name);
    return str;
}

public OnFilterScriptInit() {
    // ENTRADA: Calçada
    CreatePickup(1318, 1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z, -1); 
    Create3DTextLabel("{FFFFFF}Autoescola\n{777777}Aperte 'H' para entrar", -1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z + 0.5, 10.0, 0);

    // SAÍDA: Dentro
    CreatePickup(1318, 1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z, -1);
    Create3DTextLabel("{FFFFFF}Sair\n{777777}Aperte 'H'", -1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z + 0.5, 10.0, 0);

    // BALCÃO
    CreatePickup(1239, 1, AUTO_BALCAO_X, AUTO_BALCAO_Y, AUTO_BALCAO_Z, -1);
    Create3DTextLabel("{00FF00}Atendimento\n{FFFFFF}Use /exame", -1, AUTO_BALCAO_X, AUTO_BALCAO_Y, AUTO_BALCAO_Z + 0.5, 8.0, 0);
    
    print(">> [AUTOESCOLA 2026] Interior ID 3 Estabilizado Carregado.");
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { 
        // Entrar na Autoescola
        if(IsPlayerInRangeOfPoint(playerid, 2.0, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z)) {
            SetPlayerInterior(playerid, AUTO_INT_ID);
            SetPlayerPos(playerid, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z);
            SetPlayerFacingAngle(playerid, 270.0);
        }
        // Sair da Autoescola
        else if(IsPlayerInRangeOfPoint(playerid, 2.0, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z)) {
            SetPlayerInterior(playerid, 0);
            SetPlayerPos(playerid, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z);
        }
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(!strcmp(cmdtext, "/exame", true)) {
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, AUTO_BALCAO_X, AUTO_BALCAO_Y, AUTO_BALCAO_Z))
            return SendClientMessage(playerid, -1, "{FF0000}Vá até o balcão de atendimento!");

        ShowPlayerDialog(playerid, 9955, DIALOG_STYLE_LIST, "{00CCFF}Autoescola - Categorias", 
            "Categoria A (Moto) - $3.000\nCategoria B (Carro) - $7.000\nCategoria C (Caminhão) - $15.000", "Escolher", "Sair");
        return 1;
    }
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == 9955 && response) {
        new preco, veh;
        switch(listitem) {
            case 0: { preco = PRECO_MOTO; veh = VEH_MOTO; CategoriaTeste[playerid] = 1; }
            case 1: { preco = PRECO_CARRO; veh = VEH_CARRO; CategoriaTeste[playerid] = 2; }
            case 2: { preco = PRECO_CAMINHAO; veh = VEH_CAMINHAO; CategoriaTeste[playerid] = 3; }
        }
        
        if(GetPlayerMoney(playerid) < preco) return SendClientMessage(playerid, -1, "{FF0000}Dinheiro insuficiente!");
        
        GivePlayerMoney(playerid, -preco);
        
        // Sai do interior para a rua
        SetPlayerInterior(playerid, 0);
        SetPlayerPos(playerid, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z);
        
        EmTeste[playerid] = 1;
        CheckStep[playerid] = 0;
        
        VeiculoTeste[playerid] = CreateVehicle(veh, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z, SPAWN_V_A, 1, 1, 120);
        PutPlayerInVehicle(playerid, VeiculoTeste[playerid], 0);
        
        SetPlayerCheckpoint(playerid, 1340.0, -1660.0, 13.5, 5.0);
        SendClientMessage(playerid, 0xFFFF00FF, "[AUTOESCOLA] Teste iniciado! Dirija com cuidado.");
    }
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    if(EmTeste[playerid]) {
        CheckStep[playerid]++;
        switch(CheckStep[playerid]) {
            case 1: SetPlayerCheckpoint(playerid, 1450.0, -1750.0, 13.5, 5.0);
            case 2: SetPlayerCheckpoint(playerid, 1411.0, -1710.0, 13.5, 5.0);
            case 3: FinalizarTeste(playerid, true);
        }
    }
    return 1;
}

stock FinalizarTeste(playerid, bool:aprovado) {
    DisablePlayerCheckpoint(playerid);
    if(VeiculoTeste[playerid] != -1) {
        DestroyVehicle(VeiculoTeste[playerid]);
        VeiculoTeste[playerid] = -1;
    }
    EmTeste[playerid] = 0;
    
    if(aprovado) {
        new file[64]; format(file, 64, "%s", CNHFile(playerid));
        if(!dini_Exists(file)) dini_Create(file);
        
        if(CategoriaTeste[playerid] == 1) dini_IntSet(file, "Moto", 1);
        else if(CategoriaTeste[playerid] == 2) dini_IntSet(file, "Carro", 1);
        else if(CategoriaTeste[playerid] == 3) dini_IntSet(file, "Caminhao", 1);
        
        SendClientMessage(playerid, 0x00FF00FF, "[AUTOESCOLA] Aprovado! Licença emitida.");
    } else {
        SendClientMessage(playerid, 0xFF0000FF, "[AUTOESCOLA] Você falhou no teste.");
    }
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
    if(EmTeste[playerid] && vehicleid == VeiculoTeste[playerid]) FinalizarTeste(playerid, false);
    return 1;
}
