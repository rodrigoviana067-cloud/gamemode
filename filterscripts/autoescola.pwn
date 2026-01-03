#define FILTERSCRIPT
#include <a_samp>
#include <dini>
#include <float>

// --- CONFIGURAÇÕES DE ECONOMIA ---
#define PRECO_MOTO      3000
#define PRECO_CARRO     7000
#define PRECO_CAMINHAO  15000

// --- VEÍCULOS DE TESTE ---
#define VEH_MOTO        461 // PCJ-600
#define VEH_CARRO       405 // Sentinel
#define VEH_CAMINHAO    403 // Linerunner

// --- COORDENADAS ---
#define AUTO_EXT_X 1411.5690
#define AUTO_EXT_Y -1699.5178
#define AUTO_EXT_Z 13.5394

#define AUTO_INT_X -2029.80
#define AUTO_INT_Y -120.60
#define AUTO_INT_Z 35.20
#define AUTO_INT_ID 3

#define BALCAO_X -2024.5
#define BALCAO_Y -116.5
#define BALCAO_Z 35.2

// Spawn do Veículo (Estacionamento Market)
#define SPAWN_V_X 1400.0
#define SPAWN_V_Y -1670.0
#define SPAWN_V_Z 13.5
#define SPAWN_V_A 90.0

new EmTeste[MAX_PLAYERS];
new VeiculoTeste[MAX_PLAYERS];
new CategoriaTeste[MAX_PLAYERS]; 
new CheckStep[MAX_PLAYERS];

// Funções de Arquivo
stock CNHFile(playerid) {
    new name[MAX_PLAYER_NAME], str[64];
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), "licencas/%s.ini", name);
    return str;
}

public OnFilterScriptInit() {
    // Entrada e Saída
    CreatePickup(1318, 1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z, -1);
    Create3DTextLabel("{FFFFFF}Autoescola Nacional\n{777777}Aperte 'H' para entrar", -1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z + 0.5, 10.0, 0);

    CreatePickup(1318, 1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z, -1);
    Create3DTextLabel("{FFFFFF}Sair\n{777777}Aperte 'H'", -1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z + 0.5, 10.0, 0);

    // Balcão Secretaria
    CreatePickup(1239, 1, BALCAO_X, BALCAO_Y, BALCAO_Z, -1);
    Create3DTextLabel("{00FF00}Secretaria\n{FFFFFF}Use /exame aqui", -1, BALCAO_X, BALCAO_Y, BALCAO_Z + 0.5, 8.0, 0);

    print(">> [AUTOESCOLA 2026] Sistema Master Completo Carregado.");
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { // Tecla H
        if(IsPlayerInRangeOfPoint(playerid, 2.5, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z)) {
            SetPlayerPos(playerid, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z);
            SetPlayerInterior(playerid, AUTO_INT_ID);
        }
        else if(IsPlayerInRangeOfPoint(playerid, 2.5, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z)) {
            SetPlayerPos(playerid, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z);
            SetPlayerInterior(playerid, 0);
        }
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(!strcmp(cmdtext, "/exame", true)) {
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, BALCAO_X, BALCAO_Y, BALCAO_Z))
            return SendClientMessage(playerid, -1, "{FF0000}Vá até o balcão da secretaria!");
        
        if(EmTeste[playerid]) return SendClientMessage(playerid, -1, "Você já está em exame.");

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
        EmTeste[playerid] = 1;
        CheckStep[playerid] = 0;
        
        SetPlayerInterior(playerid, 0);
        VeiculoTeste[playerid] = CreateVehicle(veh, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z, SPAWN_V_A, 1, 1, 300);
        PutPlayerInVehicle(playerid, VeiculoTeste[playerid], 0);
        
        // Primeiro Checkpoint Geral
        SetPlayerCheckpoint(playerid, 1340.0, -1660.0, 13.5, 6.0);
        SendClientMessage(playerid, 0xFFFF00FF, "[AUTOESCOLA] Teste iniciado! Siga os checkpoints e não destrua o veículo.");
    }
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    if(EmTeste[playerid]) {
        new Float:hp;
        GetVehicleHealth(VeiculoTeste[playerid], hp);
        if(hp < 850.0) return FinalizarTeste(playerid, false);

        CheckStep[playerid]++;
        
        // PERCURSOS DIFERENCIADOS POR CATEGORIA
        if(CategoriaTeste[playerid] == 1) { // MOTO (Ágil)
            switch(CheckStep[playerid]) {
                case 1: SetPlayerCheckpoint(playerid, 1280.0, -1650.0, 13.5, 4.0);
                case 2: SetPlayerCheckpoint(playerid, 1280.0, -1720.0, 13.5, 4.0);
                case 3: FinalizarTeste(playerid, true);
            }
        }
        else if(CategoriaTeste[playerid] == 2) { // CARRO (Normal)
            switch(CheckStep[playerid]) {
                case 1: SetPlayerCheckpoint(playerid, 1340.0, -1750.0, 13.5, 6.0);
                case 2: SetPlayerCheckpoint(playerid, 1450.0, -1750.0, 13.5, 6.0);
                case 3: SetPlayerCheckpoint(playerid, 1411.0, -1710.0, 13.5, 6.0);
                case 4: FinalizarTeste(playerid, true);
            }
        }
        else if(CategoriaTeste[playerid] == 3) { // CAMINHÃO (Longo/Difícil)
            switch(CheckStep[playerid]) {
                case 1: SetPlayerCheckpoint(playerid, 1450.0, -1600.0, 13.5, 8.0);
                case 2: SetPlayerCheckpoint(playerid, 1600.0, -1600.0, 13.5, 8.0);
                case 3: SetPlayerCheckpoint(playerid, 1600.0, -1750.0, 13.5, 8.0);
                case 4: SetPlayerCheckpoint(playerid, 1411.0, -1710.0, 13.5, 8.0);
                case 5: FinalizarTeste(playerid, true);
            }
        }
    }
    return 1;
}

stock FinalizarTeste(playerid, bool:aprovado) {
    DisablePlayerCheckpoint(playerid);
    DestroyVehicle(VeiculoTeste[playerid]);
    VeiculoTeste[playerid] = -1;
    EmTeste[playerid] = 0;

    if(aprovado) {
        new file[64]; format(file, sizeof(file), "%s", CNHFile(playerid));
        if(!dini_Exists(file)) dini_Create(file);
        
        if(CategoriaTeste[playerid] == 1) dini_IntSet(file, "Moto", 1);
        else if(CategoriaTeste[playerid] == 2) dini_IntSet(file, "Carro", 1);
        else if(CategoriaTeste[playerid] == 3) dini_IntSet(file, "Caminhao", 1);
        
        SendClientMessage(playerid, 0x00FF00FF, "[AUTOESCOLA] Aprovado! Sua licença foi emitida e salva.");
    } else {
        SendClientMessage(playerid, 0xFF0000FF, "[AUTOESCOLA] Reprovado! Você danificou muito o veículo ou abandonou o teste.");
    }
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
    if(EmTeste[playerid] && vehicleid == VeiculoTeste[playerid]) FinalizarTeste(playerid, false);
    return 1;
}
