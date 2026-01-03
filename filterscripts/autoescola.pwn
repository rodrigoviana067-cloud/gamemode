#define FILTERSCRIPT
#include <a_samp>
#include <dini>

// --- CONFIGURAÇÕES ---
#define PRECO_MOTO      3000
#define PRECO_CARRO     7000
#define PRECO_CAMINHAO  15000

#define VEH_MOTO        461 
#define VEH_CARRO       405 
#define VEH_CAMINHAO    403 

#define LOCAL_MARKET    1412.0202, -1699.9926, 13.5394
#define LOCAL_INT_SAIDA -2027.9200, -105.1830, 1035.1720
#define LOCAL_BALCAO    -2030.0000, -117.0000, 1035.1720
#define ID_INTERIOR     3

#define DIALOG_AUTO     9955

new EmTeste[MAX_PLAYERS], VeiculoTeste[MAX_PLAYERS], CategoriaTeste[MAX_PLAYERS], CheckStep[MAX_PLAYERS];

// Necessário para o Timer funcionar
forward IniciarTesteAtrasado(playerid, veiculo_id);

stock ObterCaminho(playerid, buffer[], size) {
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(buffer, size, "licencas/%s.ini", name);
}

public OnFilterScriptInit() {
    CreatePickup(1318, 1, LOCAL_MARKET, 0);
    Create3DTextLabel("{00CCFF}Autoescola\n{FFFFFF}Aperte 'H' para entrar", -1, LOCAL_MARKET, 10.0, 0);

    CreatePickup(1318, 1, LOCAL_INT_SAIDA, -1);
    CreatePickup(1239, 1, LOCAL_BALCAO, -1);
    Create3DTextLabel("{FFFFFF}Balcão de Exames\n{FFFF00}Use /exame", -1, LOCAL_BALCAO, 5.0, 0);
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) {
        if(IsPlayerInRangeOfPoint(playerid, 2.0, LOCAL_MARKET)) {
            SetPlayerInterior(playerid, ID_INTERIOR);
            SetPlayerPos(playerid, LOCAL_INT_SAIDA);
        }
        else if(IsPlayerInRangeOfPoint(playerid, 2.0, LOCAL_INT_SAIDA)) {
            SetPlayerInterior(playerid, 0);
            SetPlayerPos(playerid, LOCAL_MARKET);
        }
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(!strcmp(cmdtext, "/exame", true)) {
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, LOCAL_BALCAO)) 
            return SendClientMessage(playerid, -1, "Vá até o balcão!");
        
        ShowPlayerDialog(playerid, DIALOG_AUTO, DIALOG_STYLE_LIST, "Categorias", "Moto\nCarro\nCaminhão", "Sim", "Sair");
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
        if(GetPlayerMoney(playerid) < preco) return SendClientMessage(playerid, -1, "Sem grana!");
        
        GivePlayerMoney(playerid, -preco);

        // 1. Primeiro tira o jogador do interior e leva para a rua
        SetPlayerInterior(playerid, 0); 
        SetPlayerPos(playerid, 1400.0, -1670.0, 13.5);

        // 2. Avisa o jogador e usa um TIMER (500ms) para criar o carro
        // Isso resolve o bug do menu que não inicia o teste
        SendClientMessage(playerid, -1, "Aguarde, preparando veículo de teste...");
        SetTimerEx("IniciarTesteAtrasado", 600, false, "ii", playerid, veh);
    }
    return 1;
}

// Esta função será chamada após o timer para garantir que o player já está na rua
public IniciarTesteAtrasado(playerid, veiculo_id) {
    // Destrói carro anterior se houver bug
    if(VeiculoTeste[playerid] != 0) DestroyVehicle(VeiculoTeste[playerid]);

    // Cria o veículo e coloca o player dentro
    VeiculoTeste[playerid] = CreateVehicle(veiculo_id, 1400.0, -1670.0, 13.5, 90.0, 1, 1, 120);
    
    // Pequeno truque para garantir que o player entre
    LinkVehicleToInterior(VeiculoTeste[playerid], 0);
    PutPlayerInVehicle(playerid, VeiculoTeste[playerid], 0);
    
    SetPlayerCheckpoint(playerid, 1340.0, -1660.0, 13.5, 5.0);
    EmTeste[playerid] = 1;
    SendClientMessage(playerid, 0x00FF00FF, "Teste iniciado! Siga os checkpoints.");
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    if(EmTeste[playerid]) FinalizarTeste(playerid, true);
    return 1;
}

stock FinalizarTeste(playerid, bool:aprovado) {
    DisablePlayerCheckpoint(playerid);
    DestroyVehicle(VeiculoTeste[playerid]);
    VeiculoTeste[playerid] = 0;
    EmTeste[playerid] = 0;

    if(aprovado) {
        new arquivo[64]; 
        ObterCaminho(playerid, arquivo, sizeof(arquivo));
        if(!dini_Exists(arquivo)) dini_Create(arquivo);
        
        if(CategoriaTeste[playerid] == 1) dini_IntSet(arquivo, "Moto", 1);
        else if(CategoriaTeste[playerid] == 2) dini_IntSet(arquivo, "Carro", 1);
        else if(CategoriaTeste[playerid] == 3) dini_IntSet(arquivo, "Caminhao", 1);
        
        SendClientMessage(playerid, 0x00FF00FF, "Aprovado! Licença salva.");
    }
    return 1;
}
