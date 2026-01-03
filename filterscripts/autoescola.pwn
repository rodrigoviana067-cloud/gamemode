#define FILTERSCRIPT
#include <a_samp>
#include <dini>
#include <float>

// --- ECONOMIA 2026 ---
#define PRECO_MOTO      3000
#define PRECO_CARRO     7000
#define PRECO_CAMINHAO  15000

// --- VEÍCULOS ---
#define VEH_MOTO        461 
#define VEH_CARRO       405 
#define VEH_CAMINHAO    403 

// --- COORDENADAS ---
#define AUTO_EXT_X 1411.5690
#define AUTO_EXT_Y -1699.5178
#define AUTO_EXT_Z 13.5394

#define AUTO_INT_X 2033.4274
#define AUTO_INT_Y 117.3727
#define AUTO_INT_Z 1035.3000 
#define AUTO_INT_ID 3

// Spawn do Veículo (Lado de fora em Market)
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
    // 1. Desativa portas amarelas nativas (Evita ir para outra cidade)
    DisableInteriorEnterExits();

    // 2. Cria Pickups Brancos (1318)
    CreatePickup(1318, 1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z, -1); 
    CreatePickup(1318, 1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z, -1);
    
    // 3. Texto no Balcão
    Create3DTextLabel("{00FF00}Atendimento Autoescola\n{FFFFFF}Use /exame", -1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z + 0.3, 8.0, 0);
    
    print(">> [AUTOESCOLA 2026] Sistema Completo e Protegido Carregado.");
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { // Tecla H
        if(IsPlayerInRangeOfPoint(playerid, 2.5, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z)) {
            SetPlayerInterior(playerid, AUTO_INT_ID);
            SetPlayerPos(playerid, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z);
            TogglePlayerControllable(playerid, false); // Anti-queda
            SetTimerEx("DescongelarPlayer", 1500, false, "i", playerid);
        }
        else if(IsPlayerInRangeOfPoint(playerid, 2.5, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z)) {
            SetPlayerInterior(playerid, 0);
            SetPlayerPos(playerid, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z);
            TogglePlayerControllable(playerid, false); // Anti-queda
            SetTimerEx("DescongelarPlayer", 1500, false, "i", playerid);
        }
    }
    return 1;
}

forward DescongelarPlayer(playerid);
public DescongelarPlayer(playerid) {
    TogglePlayerControllable(playerid, true);
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(!strcmp(cmdtext, "/exame", true)) {
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z)) 
            return SendClientMessage(playerid, -1, "{FF0000}Vá até o balcão!");
            
        ShowPlayerDialog(playerid, 9955, DIALOG_STYLE_LIST, "{00CCFF}Categorias CNH", "Moto ($3k)\nCarro ($7k)\nCaminhão ($15k)", "Iniciar", "Sair");
        return 1;
    }
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == 9955 && response) {
        new vModel, preco;
        if(listitem == 0) { preco = PRECO_MOTO; vModel = VEH_MOTO; CategoriaTeste[playerid] = 1; }
        else if(listitem == 1) { preco = PRECO_CARRO; vModel = VEH_CARRO; CategoriaTeste[playerid] = 2; }
        else if(listitem == 2) { preco = PRECO_CAMINHAO; vModel = VEH_CAMINHAO; CategoriaTeste[playerid] = 3; }
        
        if(GetPlayerMoney(playerid) < preco) return SendClientMessage(playerid, -1, "Sem dinheiro!");
        
        GivePlayerMoney(playerid, -preco);
        SetPlayerInterior(playerid, 0);
        EmTeste[playerid] = 1; CheckStep[playerid] = 0;
        VeiculoTeste[playerid] = CreateVehicle(vModel, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z, SPAWN_V_A, 1, 1, 300);
        PutPlayerInVehicle(playerid, VeiculoTeste[playerid], 0);
        SetPlayerCheckpoint(playerid, 1340.0, -1660.0, 13.5, 6.0); 
        SendClientMessage(playerid, 0xFFFF00FF, "[AUTOESCOLA] Teste iniciado! Não bata.");
    }
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    if(EmTeste[playerid]) {
        new Float:hp; GetVehicleHealth(VeiculoTeste[playerid], hp);
        if(hp < 850.0) return FinalizarTeste(playerid, false);
        CheckStep[playerid]++;
        
        if(CategoriaTeste[playerid] == 1) { // MOTO
            if(CheckStep[playerid] == 1) SetPlayerCheckpoint(playerid, 1280.0, -1720.0, 13.5, 4.0);
            else FinalizarTeste(playerid, true);
        }
        else if(CategoriaTeste[playerid] == 2) { // CARRO
            if(CheckStep[playerid] == 1) SetPlayerCheckpoint(playerid, 1450.0, -1750.0, 13.5, 6.0);
            else if(CheckStep[playerid] == 2) SetPlayerCheckpoint(playerid, 1411.0, -1710.0, 13.5, 6.0);
            else FinalizarTeste(playerid, true);
        }
        else if(CategoriaTeste[playerid] == 3) { // CAMINHÃO
            if(CheckStep[playerid] == 1) SetPlayerCheckpoint(playerid, 1600.0, -1600.0, 13.5, 8.0);
            else if(CheckStep[playerid] == 2) SetPlayerCheckpoint(playerid, 1411.0, -1710.0, 13.5, 8.0);
            else FinalizarTeste(playerid, true);
        }
    }
    return 1;
}

stock FinalizarTeste(playerid, bool:aprovado) {
    DisablePlayerCheckpoint(playerid);
    if(VeiculoTeste[playerid] != -1) DestroyVehicle(VeiculoTeste[playerid]);
    VeiculoTeste[playerid] = -1;
    EmTeste[playerid] = 0;
    if(aprovado) {
        new file[64]; format(file, sizeof(file), "%s", CNHFile(playerid));
        if(!dini_Exists(file)) dini_Create(file);
        if(CategoriaTeste[playerid] == 1) dini_IntSet(file, "Moto", 1);
        else if(CategoriaTeste[playerid] == 2) dini_IntSet(file, "Carro", 1);
        else if(CategoriaTeste[playerid] == 3) dini_IntSet(file, "Caminhao", 1);
        SendClientMessage(playerid, 0x00FF00FF, "[AUTOESCOLA] Aprovado! Licença emitida.");
    } else SendClientMessage(playerid, 0xFF0000FF, "[AUTOESCOLA] Reprovado!");
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
    if(EmTeste[playerid] && vehicleid == VeiculoTeste[playerid]) FinalizarTeste(playerid, false);
    return 1;
}
