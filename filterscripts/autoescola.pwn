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

// --- COORDENADAS REVISADAS ---
#define AUTO_EXT_X 1411.5690
#define AUTO_EXT_Y -1699.5178
#define AUTO_EXT_Z 13.5394

// Coordenada interna no centro da recepção (mais segura contra queda)
#define AUTO_INT_X 2041.130
#define AUTO_INT_Y 159.200
#define AUTO_INT_Z 1061.200 
#define AUTO_INT_ID 3

// Balcão de Atendimento (Dentro)
#define AUTO_INFO_X 2045.0
#define AUTO_INFO_Y 156.0
#define AUTO_INFO_Z 1061.1

// Spawn do Veículo (Lado de fora)
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
    // ENTRADA
    CreatePickup(1318, 1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z, 0); 
    Create3DTextLabel("{FFFFFF}Autoescola\n{777777}Aperte 'H' para entrar", -1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z + 0.5, 10.0, 0);

    // SAÍDA (Dentro do interior ID 3)
    CreatePickup(1318, 1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z, 0);
    Create3DTextLabel("{FFFFFF}Sair\n{777777}Aperte 'H'", -1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z + 0.5, 10.0, 0);

    // BALCÃO
    CreatePickup(1239, 1, AUTO_INFO_X, AUTO_INFO_Y, AUTO_INFO_Z, 0);
    Create3DTextLabel("{00FF00}Atendimento\n{FFFFFF}Use /exame", -1, AUTO_INFO_X, AUTO_INFO_Y, AUTO_INFO_Z + 0.5, 8.0, 0);
    
    print(">> [AUTOESCOLA 2026] Sistema com Proteção Anti-Limbo Carregado.");
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { 
        // Entrar
        if(IsPlayerInRangeOfPoint(playerid, 2.5, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z)) {
            TogglePlayerControllable(playerid, false); // Congela
            SetPlayerInterior(playerid, AUTO_INT_ID);
            SetPlayerPos(playerid, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z + 0.5); // Spawna um pouco acima do chão
            SetTimerEx("DescongelarPlayer", 2000, false, "i", playerid); // 2 segundos para carregar
        }
        // Sair
        else if(IsPlayerInRangeOfPoint(playerid, 2.5, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z)) {
            TogglePlayerControllable(playerid, false);
            SetPlayerInterior(playerid, 0);
            SetPlayerPos(playerid, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z);
            SetTimerEx("DescongelarPlayer", 2000, false, "i", playerid);
        }
    }
    return 1;
}

forward DescongelarPlayer(playerid);
public DescongelarPlayer(playerid) {
    TogglePlayerControllable(playerid, true);
    SetCameraBehindPlayer(playerid);
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(!strcmp(cmdtext, "/exame", true)) {
        if(!IsPlayerInRangeOfPoint(playerid, 4.0, AUTO_INFO_X, AUTO_INFO_Y, AUTO_INFO_Z))
            return SendClientMessage(playerid, -1, "{FF0000}Vá até o balcão!");

        ShowPlayerDialog(playerid, 9955, DIALOG_STYLE_LIST, "Categorias CNH", "Moto ($3k)\nCarro ($7k)\nCaminhão ($15k)", "Iniciar", "Sair");
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
        SetPlayerPos(playerid, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z + 1.0); 
        
        EmTeste[playerid] = 1; 
        CheckStep[playerid] = 0;
        VeiculoTeste[playerid] = CreateVehicle(vModel, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z, SPAWN_V_A, 1, 1, 300);
        
        SetTimerEx("PutInVeh", 1000, false, "ii", playerid, VeiculoTeste[playerid]);
        SetPlayerCheckpoint(playerid, 1340.0, -1660.0, 13.5, 6.0); 
        SendClientMessage(playerid, -1, "Teste iniciado!");
    }
    return 1;
}

forward PutInVeh(playerid, vehicleid);
public PutInVeh(playerid, vehicleid) {
    PutPlayerInVehicle(playerid, vehicleid, 0);
}

public OnPlayerEnterCheckpoint(playerid) {
    if(EmTeste[playerid]) {
        CheckStep[playerid]++;
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
    if(aprovado) SendClientMessage(playerid, 0x00FF00FF, "Aprovado!");
    else SendClientMessage(playerid, 0xFF0000FF, "Reprovado!");
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
    if(EmTeste[playerid] && vehicleid == VeiculoTeste[playerid]) FinalizarTeste(playerid, false);
    return 1;
}
