#define FILTERSCRIPT
#include <a_samp>
#include <dini>

// --- CONFIGURAÇÕES AUTOESCOLA 2026 ---
#define PRECO_MOTO      3000
#define PRECO_CARRO     7000
#define PRECO_CAMINHAO  15000

// Veículos
#define VEH_MOTO        461 
#define VEH_CARRO       405 
#define VEH_CAMINHAO    403 

// 1. Pickup de ENTRADA (Calçada de Market que você passou antes)
#define LOCAL_MARKET    1412.0202, -1699.9926, 13.5394

// 2. NOVAS COORDENADAS (Interior da Autoescola SF)
#define LOCAL_INT_SAIDA -2027.9200, -105.1830, 1035.1720
#define ID_INTERIOR     3

// 3. Balcão para o /exame (Um pouco à frente de onde você aparece)
#define LOCAL_BALCAO    -2030.0000, -117.0000, 1035.1720

#define DIALOG_AUTO     9955

new EmTeste[MAX_PLAYERS], VeiculoTeste[MAX_PLAYERS], CategoriaTeste[MAX_PLAYERS], CheckStep[MAX_PLAYERS];

// Função de salvamento sem erros de compilação
stock CNHFile(playerid, path[], size) {
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(path, size, "licencas/%s.ini", name);
}

public OnFilterScriptInit() {
    // Pickup na RUA (Entrada)
    CreatePickup(1318, 1, LOCAL_MARKET, 0);
    Create3DTextLabel("{00CCFF}Autoescola\n{FFFFFF}Aperte 'H' para entrar", -1, LOCAL_MARKET, 10.0, 0);

    // Pickup DENTRO (Saída)
    CreatePickup(1318, 1, LOCAL_INT_SAIDA, -1);

    // Pickup do BALCÃO (Onde usa o /exame)
    CreatePickup(1239, 1, LOCAL_BALCAO, -1);
    Create3DTextLabel("{FFFFFF}Balcão de Exames\n{FFFF00}Use /exame", -1, LOCAL_BALCAO, 5.0, 0);
    
    print(">> [AUTOESCOLA 2026] Coordenadas SF configuradas.");
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { // Tecla H
        // ENTRAR
        if(IsPlayerInRangeOfPoint(playerid, 2.0, LOCAL_MARKET)) {
            SetPlayerInterior(playerid, ID_INTERIOR); // Evita cair do chão
            SetPlayerPos(playerid, LOCAL_INT_SAIDA);
        }
        // SAIR
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
            return SendClientMessage(playerid, -1, "{FF0000}Vá até o balcão!");
        
        ShowPlayerDialog(playerid, DIALOG_AUTO, DIALOG_STYLE_LIST, "{00CCFF}Categorias", 
            "Moto - $3.000\nCarro - $7.000\nCaminhão - $15.000", "Escolher", "Sair");
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

        if(GetPlayerMoney(playerid) < preco) return SendClientMessage(playerid, -1, "{FF0000}Sem grana!");
        
        GivePlayerMoney(playerid, -preco);
        
        // Inicia o teste saindo do interior
        SetPlayerInterior(playerid, 0); 
        SetPlayerPos(playerid, 1400.0, -1670.0, 13.5);

        VeiculoTeste[playerid] = CreateVehicle(veh, 1400.0, -1670.0, 13.5, 90.0, 1, 1, 120);
        PutPlayerInVehicle(playerid, VeiculoTeste[playerid], 0);
        
        SetPlayerCheckpoint(playerid, 1340.0, -1660.0, 13.5, 5.0);
        EmTeste[playerid] = 1;
        CheckStep[playerid] = 0;
        SendClientMessage(playerid, 0xFFFF00FF, "Teste iniciado!");
    }
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    if(EmTeste[playerid]) {
        CheckStep[playerid]++;
        switch(CheckStep[playerid]) {
            case 1: SetPlayerCheckpoint(playerid, 1300.0, -1660.0, 13.5, 5.0);
            case 2: FinalizarTeste(playerid, true);
        }
    }
    return 1;
}

stock FinalizarTeste(playerid, bool:aprovado) {
    DisablePlayerCheckpoint(playerid);
    DestroyVehicle(VeiculoTeste[playerid]);
    EmTeste[playerid] = 0;

    if(aprovado) {
        new path;
        CNHFile(playerid, path, sizeof(path));
        if(!dini_Exists(path)) dini_Create(path);
        
        if(CategoriaTeste[playerid] == 1) dini_IntSet(path, "Moto", 1);
        else if(CategoriaTeste[playerid] == 2) dini_IntSet(path, "Carro", 1);
        else if(CategoriaTeste[playerid] == 3) dini_IntSet(path, "Caminhao", 1);
        
        SendClientMessage(playerid, 0x00FF00FF, "Aprovado! Licença salva.");
    }
    return 1;
}
