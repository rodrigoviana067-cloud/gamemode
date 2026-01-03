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

// --- COORDENADAS AJUSTADAS ---
// Calçada da Autoescola (Sua coordenada)
#define AUTO_EXT_X 1412.0202
#define AUTO_EXT_Y -1699.9926
#define AUTO_EXT_Z 13.5394

// NOVO INTERIOR 15 (Ultra Estável - Não cai no limbo)
#define AUTO_INT_X 2231.2000
#define AUTO_INT_Y -1147.1000
#define AUTO_INT_Z 1050.7000
#define AUTO_INT_ID 15

// Balcão de Atendimento (Dentro do Interior 15)
#define AUTO_INFO_X 2228.5000
#define AUTO_INFO_Y -1149.0000
#define AUTO_INFO_Z 1050.7000

// Spawn do Veículo (Rua)
#define SPAWN_V_X 1400.0
#define SPAWN_V_Y -1670.0
#define SPAWN_V_Z 13.5
#define SPAWN_V_A 90.0

new EmTeste[MAX_PLAYERS], VeiculoTeste[MAX_PLAYERS], CategoriaTeste[MAX_PLAYERS], CheckStep[MAX_PLAYERS];

// Funções de salvamento
stock CNHFile(playerid) {
    new name[MAX_PLAYER_NAME], str[64];
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), "licencas/%s.ini", name);
    return str;
}

forward DescongelarPlayer(playerid);
public DescongelarPlayer(playerid) {
    TogglePlayerControllable(playerid, true);
    SetCameraBehindPlayer(playerid);
    return 1;
}

public OnFilterScriptInit() {
    // ENTRADA: Calçada
    CreatePickup(1318, 1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z, 0); 
    Create3DTextLabel("{FFFFFF}Autoescola\n{777777}Aperte 'H' para entrar", -1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z + 0.5, 10.0, 0);

    // SAÍDA: Interior 15
    CreatePickup(1318, 1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z, 0);
    Create3DTextLabel("{FFFFFF}Sair\n{777777}Aperte 'H'", -1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z + 0.5, 10.0, 0);

    // BALCÃO
    CreatePickup(1239, 1, AUTO_INFO_X, AUTO_INFO_Y, AUTO_INFO_Z, 0);
    Create3DTextLabel("{00FF00}Central de Exames\n{FFFFFF}Use /exame", -1, AUTO_INFO_X, AUTO_INFO_Y, AUTO_INFO_Z + 0.5, 8.0, 0);
    
    print(">> [AUTOESCOLA 2026] Interior 15 Ativado - Sem Limbo.");
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { // Tecla H
        // ENTRAR
        if(IsPlayerInRangeOfPoint(playerid, 2.0, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z)) {
            TogglePlayerControllable(playerid, false);
            SetPlayerInterior(playerid, AUTO_INT_ID);
            SetPlayerPos(playerid, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z + 0.2);
            SetTimerEx("DescongelarPlayer", 1500, false, "i", playerid);
        }
        // SAIR
        else if(IsPlayerInRangeOfPoint(playerid, 2.0, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z)) {
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
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, AUTO_INFO_X, AUTO_INFO_Y, AUTO_INFO_Z))
            return SendClientMessage(playerid, -1, "{FF0000}Vá até o balcão!");

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
        SetPlayerInterior(playerid, 0);
        SetPlayerPos(playerid, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z);
        
        EmTeste[playerid] = 1;
        CheckStep[playerid] = 0;
        VeiculoTeste[playerid] = CreateVehicle(veh, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z, SPAWN_V_A, 1, 1, 120);
        
        // Timer de 1 segundo para colocar no carro após sair do interior
        SetTimerEx("ColocarNoCarro", 1000, false, "ii", playerid, VeiculoTeste[playerid]);
        
        SetPlayerCheckpoint(playerid, 1340.0, -1660.0, 13.5, 5.0);
        SendClientMessage(playerid, 0xFFFF00FF, "[AUTOESCOLA] Teste iniciado na rua!");
    }
    return 1;
}

forward ColocarNoCarro(playerid, veiculo);
public ColocarNoCarro(playerid, veiculo) {
    PutPlayerInVehicle(playerid, veiculo, 0);
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
        
        SendClientMessage(playerid, 0x00FF00FF, "[AUTOESCOLA] Aprovado!");
    } else SendClientMessage(playerid, 0xFF0000FF, "[AUTOESCOLA] Falhou!");
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
    if(EmTeste[playerid] && vehicleid == VeiculoTeste[playerid]) FinalizarTeste(playerid, false);
    return 1;
}
