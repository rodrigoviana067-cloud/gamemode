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

// --- COORDENADAS ESTILO PREFEITURA (AJUSTADAS) ---
// Lado de Fora
#define AUTO_EXT_X 1411.5690
#define AUTO_EXT_Y -1699.5178
#define AUTO_EXT_Z 13.5394

// Lado de Dentro (Interior ID 3 - Autoescola)
#define AUTO_INT_X 2041.05  // Coordenada central estável
#define AUTO_INT_Y 155.03
#define AUTO_INT_Z 1061.10
#define AUTO_INT_ID 3

// Balcão de Atendimento (Dentro)
#define AUTO_INFO_X 2045.0
#define AUTO_INFO_Y 156.0
#define AUTO_INFO_Z 1061.1

// Spawn do Veículo no Exame (Lado de fora)
#define SPAWN_V_X 1400.0
#define SPAWN_V_Y -1670.0
#define SPAWN_V_Z 13.5
#define SPAWN_V_A 90.0

new EmTeste[MAX_PLAYERS], VeiculoTeste[MAX_PLAYERS], CategoriaTeste[MAX_PLAYERS], CheckStep[MAX_PLAYERS];

// Funções de arquivo
stock CNHFile(playerid) {
    new name[MAX_PLAYER_NAME], str[64];
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), "licencas/%s.ini", name);
    return str;
}

public OnFilterScriptInit() {
    // ENTRADA
    CreatePickup(1318, 1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z, -1); 
    Create3DTextLabel("{FFFFFF}Autoescola\n{777777}Aperte 'H' para entrar", -1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z + 0.5, 10.0, 0);

    // SAÍDA
    CreatePickup(1318, 1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z, -1);
    Create3DTextLabel("{FFFFFF}Sair\n{777777}Aperte 'H'", -1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z + 0.5, 10.0, 0);

    // BALCÃO
    CreatePickup(1239, 1, AUTO_INFO_X, AUTO_INFO_Y, AUTO_INFO_Z, -1);
    Create3DTextLabel("{00FF00}Atendimento\n{FFFFFF}Use /exame", -1, AUTO_INFO_X, AUTO_INFO_Y, AUTO_INFO_Z + 0.5, 8.0, 0);
    
    print(">> [AUTOESCOLA 2026] Ajustada pelo padrao da Prefeitura.");
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { // Tecla H
        // Entrar
        if(IsPlayerInRangeOfPoint(playerid, 2.0, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z)) {
            SetPlayerPos(playerid, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z);
            SetPlayerInterior(playerid, AUTO_INT_ID);
        }
        // Sair
        else if(IsPlayerInRangeOfPoint(playerid, 2.0, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z)) {
            SetPlayerPos(playerid, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z);
            SetPlayerInterior(playerid, 0);
        }
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(!strcmp(cmdtext, "/exame", true)) {
        if(!IsPlayerInRangeOfPoint(playerid, 4.0, AUTO_INFO_X, AUTO_INFO_Y, AUTO_INFO_Z))
            return SendClientMessage(playerid, -1, "{FF0000}[ERRO] Voce deve estar no balcao!");

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
        SetPlayerPos(playerid, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z); // Teleporta o player para fora antes de criar o carro
        
        EmTeste[playerid] = 1; 
        CheckStep[playerid] = 0;
        VeiculoTeste[playerid] = CreateVehicle(vModel, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z, SPAWN_V_A, 1, 1, 300);
        
        PutPlayerInVehicle(playerid, VeiculoTeste[playerid], 0);
        SetPlayerCheckpoint(playerid, 1340.0, -1660.0, 13.5, 6.0); 
        SendClientMessage(playerid, 0xFFFF00FF, "[AUTOESCOLA] Teste iniciado!");
    }
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    if(EmTeste[playerid]) {
        CheckStep[playerid]++;
        // Lógica simplificada de checkpoints (Exemplo: 2 checkpoints e termina)
        if(CheckStep[playerid] == 1) SetPlayerCheckpoint(playerid, 1450.0, -1750.0, 13.5, 6.0);
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
        new file[64]; format(file, sizeof(file), "%s", CNHFile(playerid));
        if(!dini_Exists(file)) dini_Create(file);
        if(CategoriaTeste[playerid] == 1) dini_IntSet(file, "Moto", 1);
        else if(CategoriaTeste[playerid] == 2) dini_IntSet(file, "Carro", 1);
        else if(CategoriaTeste[playerid] == 3) dini_IntSet(file, "Caminhao", 1);
        SendClientMessage(playerid, 0x00FF00FF, "[AUTOESCOLA] Aprovado!");
    } else SendClientMessage(playerid, 0xFF0000FF, "[AUTOESCOLA] Reprovado!");
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
    if(EmTeste[playerid] && vehicleid == VeiculoTeste[playerid]) FinalizarTeste(playerid, false);
    return 1;
}
