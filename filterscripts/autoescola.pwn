#define FILTERSCRIPT
#include <a_samp>
#include <dini>

// Preços por Categoria (Economia 2026)
#define PRECO_MOTO      3000
#define PRECO_CARRO     7000
#define PRECO_CAMINHAO  15000

// Veículos de Teste
#define VEH_MOTO        461 // PCJ-600
#define VEH_CARRO       405 // Sentinel
#define VEH_CAMINHAO    403 // Linerunner

// --- COORDENADAS MARKET ---
#define LOCAL_AUTO      1412.0202, -1699.9926, 13.5394
#define SPAWN_CARRO     1400.0, -1670.0, 13.5
#define DIALOG_AUTO     9955

new EmTeste[MAX_PLAYERS];
new VeiculoTeste[MAX_PLAYERS];
new CategoriaTeste[MAX_PLAYERS]; 
new CheckStep[MAX_PLAYERS];

// Função de caminho corrigida para evitar erros 035 e 239
stock ObterCaminho(playerid, arquivo[], size) {
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(arquivo, size, "licencas/%s.ini", name);
}

public OnFilterScriptInit() {
    // Adicionando o pickup na calçada de Market
    CreatePickup(1239, 1, LOCAL_AUTO, -1);
    Create3DTextLabel("{FFFFFF}Autoescola LS 2026\n{FFFF00}Use /exame", -1, LOCAL_AUTO, 10.0, 0);
    
    print(">> [AUTOESCOLA 2026] Pickup em Market e categorias prontas.");
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(!strcmp(cmdtext, "/exame", true)) {
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, LOCAL_AUTO)) 
            return SendClientMessage(playerid, -1, "{FF0000}Vá até a marca da Autoescola em Market!");
        
        ShowPlayerDialog(playerid, DIALOG_AUTO, DIALOG_STYLE_LIST, "{00CCFF}Autoescola - Categorias", 
            "Categoria A (Moto) - $3.000\nCategoria B (Carro) - $7.000\nCategoria C (Caminhão) - $15.000", "Escolher", "Sair");
        return 1;
    }
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == DIALOG_AUTO && response) {
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
        
        // Spawn do veículo na rua (Market)
        VeiculoTeste[playerid] = CreateVehicle(veh, SPAWN_CARRO, 90.0, 1, 1, 120);
        PutPlayerInVehicle(playerid, VeiculoTeste[playerid], 0);
        
        // Primeiro Checkpoint próximo à rua de Market
        SetPlayerCheckpoint(playerid, 1340.0, -1660.0, 13.5, 5.0);
        SendClientMessage(playerid, 0xFFFF00FF, "[AUTOESCOLA] Teste iniciado! Siga os checkpoints.");
    }
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    if(EmTeste[playerid]) {
        CheckStep[playerid]++;
        switch(CheckStep[playerid]) {
            case 1: SetPlayerCheckpoint(playerid, 1280.0, -1660.0, 13.5, 5.0);
            case 2: SetPlayerCheckpoint(playerid, 1405.0, -1690.0, 13.5, 5.0);
            case 3: FinalizarTeste(playerid, true);
        }
    }
    return 1;
}

stock FinalizarTeste(playerid, bool:aprovado) {
    DisablePlayerCheckpoint(playerid);
    if(IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);
    
    DestroyVehicle(VeiculoTeste[playerid]);
    VeiculoTeste[playerid] = 0;
    EmTeste[playerid] = 0;

    if(aprovado) {
        new path; // String para armazenar o caminho
        ObterCaminho(playerid, path, sizeof(path));
        
        if(!dini_Exists(path)) dini_Create(path);
        
        if(CategoriaTeste[playerid] == 1) dini_IntSet(path, "Moto", 1);
        else if(CategoriaTeste[playerid] == 2) dini_IntSet(path, "Carro", 1);
        else if(CategoriaTeste[playerid] == 3) dini_IntSet(path, "Caminhao", 1);
        
        SendClientMessage(playerid, 0x00FF00FF, "[AUTOESCOLA] Aprovado! Licença emitida em Market.");
    } else {
        SendClientMessage(playerid, 0xFF0000FF, "[AUTOESCOLA] Você falhou no teste.");
    }
    return 1;
}
