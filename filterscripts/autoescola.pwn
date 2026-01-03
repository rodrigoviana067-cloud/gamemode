#define FILTERSCRIPT
#include <a_samp>
#include <dini>

// --- CONFIGURAÇÕES ---
#define PRECO_AUTO      3000
#define ID_DIALOG_TESTE 9855 // ID alto para evitar conflitos
#define VEH_CARRO       405 

// Coordenadas
#define LOCAL_MARKET    1412.0202, -1699.9926, 13.5394
#define LOCAL_INT_SAIDA -2027.9200, -105.1830, 1035.1720
#define LOCAL_BALCAO    -2030.0000, -117.0000, 1035.1720
#define SPAWN_TESTE     1400.0, -1670.0, 13.5
#define ID_INTERIOR     3

new EmTeste[MAX_PLAYERS], VeiculoTeste[MAX_PLAYERS];

forward IniciarTesteReal(playerid);

public OnFilterScriptInit() {
    CreatePickup(1318, 1, LOCAL_MARKET, 0); // Entrada
    CreatePickup(1239, 1, LOCAL_BALCAO, -1); // Balcão
    Create3DTextLabel("Balcão de Exames\nUse /exame", -1, LOCAL_BALCAO, 5.0, 0);
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { // Tecla H
        if(IsPlayerInRangeOfPoint(playerid, 2.0, LOCAL_MARKET)) {
            SetPlayerInterior(playerid, ID_INTERIOR);
            SetPlayerPos(playerid, LOCAL_INT_SAIDA);
        } else if(IsPlayerInRangeOfPoint(playerid, 2.0, LOCAL_INT_SAIDA)) {
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
        
        // Usando MSGBOX simples para testar a resposta
        ShowPlayerDialog(playerid, ID_DIALOG_TESTE, DIALOG_STYLE_MSGBOX, "AUTOESCOLA", "Deseja pagar $3000 e iniciar o teste?", "Sim", "Sair");
        return 1;
    }
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == ID_DIALOG_TESTE) {
        if(!response) return SendClientMessage(playerid, -1, "Teste cancelado.");

        if(GetPlayerMoney(playerid) < PRECO_AUTO) 
            return SendClientMessage(playerid, -1, "Você não tem dinheiro!");

        GivePlayerMoney(playerid, -PRECO_AUTO);
        
        // Tira do interior primeiro
        SetPlayerInterior(playerid, 0);
        SetPlayerPos(playerid, SPAWN_TESTE);
        
        // Delay essencial para o mapa carregar antes do carro aparecer
        SendClientMessage(playerid, -1, "Iniciando teste, aguarde...");
        SetTimerEx("IniciarTesteReal", 1000, false, "i", playerid);
        return 1;
    }
    return 0;
}

public IniciarTesteReal(playerid) {
    if(VeiculoTeste[playerid] != 0) DestroyVehicle(VeiculoTeste[playerid]);

    VeiculoTeste[playerid] = CreateVehicle(VEH_CARRO, SPAWN_TESTE, 90.0, 1, 1, 300);
    PutPlayerInVehicle(playerid, VeiculoTeste[playerid], 0);
    
    SetPlayerCheckpoint(playerid, 1340.0, -1660.0, 13.5, 5.0);
    EmTeste[playerid] = 1;
    SendClientMessage(playerid, 0x00FF00FF, "Siga o checkpoint!");
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    if(EmTeste[playerid]) {
        SendClientMessage(playerid, 0x00FF00FF, "Parabéns! Você passou.");
        DisablePlayerCheckpoint(playerid);
        DestroyVehicle(VeiculoTeste[playerid]);
        VeiculoTeste[playerid] = 0;
        EmTeste[playerid] = 0;
    }
    return 1;
}
