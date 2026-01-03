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
// Entrada de Market (Lado de fora)
#define AUTO_EXT_X 1411.5690
#define AUTO_EXT_Y -1699.5178
#define AUTO_EXT_Z 13.5394

// Ponto de nascimento dentro (Interior)
#define AUTO_INT_X 2033.4274
#define AUTO_INT_Y 117.3727
#define AUTO_INT_Z 1035.1718
#define AUTO_INT_ID 3

// Balcão de Atendimento (Onde usa /exame)
#define BALCAO_X 2033.4274
#define BALCAO_Y 117.3727
#define BALCAO_Z 1035.1718

// Spawn do Veículo (Lado de fora no estacionamento)
#define SPAWN_V_X 1400.0
#define SPAWN_V_Y -1670.0
#define SPAWN_V_Z 13.5
#define SPAWN_V_A 90.0

new EmTeste[MAX_PLAYERS];
new VeiculoTeste[MAX_PLAYERS];
new CategoriaTeste[MAX_PLAYERS]; 
new CheckStep[MAX_PLAYERS];

stock CNHFile(playerid) {
    new name[MAX_PLAYER_NAME], str[64];
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), "licencas/%s.ini", name);
    return str;
}

public OnFilterScriptInit() {
    // Porta de Fora
    CreatePickup(1318, 1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z, -1);
    Create3DTextLabel("{FFFFFF}Autoescola Nacional\n{777777}Aperte 'H' para entrar", -1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z + 0.5, 10.0, 0);

    // Porta de Sair (Dentro)
    CreatePickup(1318, 1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z, -1);
    Create3DTextLabel("{FFFFFF}Sair\n{777777}Aperte 'H'", -1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z + 0.5, 10.0, 0);

    // Balcão Secretaria (Novo local solicitado)
    CreatePickup(1239, 1, BALCAO_X, BALCAO_Y, BALCAO_Z, -1);
    Create3DTextLabel("{00FF00}Atendimento CNH\n{FFFFFF}Use /exame aqui", -1, BALCAO_X, BALCAO_Y, BALCAO_Z + 0.5, 8.0, 0);
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
            return SendClientMessage(playerid, -1, "{FF0000}Vá até o balcão de atendimento!");
        
        if(EmTeste[playerid]) return SendClientMessage(playerid, -1, "Você já está realizando um teste.");

        ShowPlayerDialog(playerid, 9955, DIALOG_STYLE_LIST, "{00CCFF}Autoescola 2026 - Categorias", 
            "Categoria A (Moto) - $3.000\nCategoria B (Carro) - $7.000\nCategoria C (Caminhão) - $15.000", "Iniciar", "Sair");
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

        if(GetPlayerMoney(playerid) < preco) return SendClientMessage(playerid, -1, "{FF0000}Você não tem dinheiro suficiente!");
        
        GivePlayerMoney(playerid, -preco);
        EmTeste[playerid] = 1;
        CheckStep[playerid] = 0;
        
        SetPlayerInterior(playerid, 0); // Sai do interior para o mapa
        VeiculoTeste[playerid] = CreateVehicle(veh, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z, SPAWN_V_A, 1, 1, 300);
        PutPlayerInVehicle(playerid, VeiculoTeste[playerid], 0);
        
        SetPlayerCheckpoint(playerid, 1340.0, -1660.0, 13.5, 6.0);
        SendClientMessage(playerid, 0xFFFF00FF, "[AUTOESCOLA] Teste iniciado! Siga os checkpoints com cuidado.");
    }
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    if(EmTeste[playerid]) {
        new Float:hp;
        GetVehicleHealth(VeiculoTeste[playerid], hp);
        if(hp < 850.0) return FinalizarTeste(playerid, false);

        CheckStep[playerid]++;
        
        if(CategoriaTeste[playerid] == 1) { // MOTO
            switch(CheckStep[playerid]) {
                case 1: SetPlayerCheckpoint(playerid, 1280.0, -1720.0, 13.5, 4.0);
                case 2: FinalizarTeste(playerid, true);
            }
        }
        else if(CategoriaTeste[playerid] == 2) { // CARRO
            switch(CheckStep[playerid]) {
                case 1: SetPlayerCheckpoint(playerid, 1340.0, -1750.0, 13.5, 6.0);
                case 2: SetPlayerCheckpoint(playerid, 1411.0, -1710.0, 13.5, 6.0);
                case 3: FinalizarTeste(playerid, true);
            }
        }
        else if(CategoriaTeste[playerid] == 3) { // CAMINHÃO
            switch(CheckStep[playerid]) {
                case 1: SetPlayerCheckpoint(playerid, 1600.0, -1600.0, 13.5, 8.0);
                case 2: SetPlayerCheckpoint(playerid, 1411.0, -1710.0, 13.5, 8.0);
                case 3: FinalizarTeste(playerid, true);
            }
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
    } else {
        SendClientMessage(playerid, 0xFF0000FF, "[AUTOESCOLA] Reprovado por danos ao veículo ou abandono.");
    }
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
    if(EmTeste[playerid] && vehicleid == VeiculoTeste[playerid]) FinalizarTeste(playerid, false);
    return 1;
}
