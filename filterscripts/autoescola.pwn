#define FILTERSCRIPT
#include <a_samp>
#include <dini>

// --- CONFIGURAÇÕES AUTOESCOLA 2026 ---
#define PRECO_AUTO      3000
#define AUTO_VW_ESPECIAL 10 // Mundo Virtual pra não ver o povo da prefeitura

// Calçada da Autoescola (Market)
#define AUTO_EXT_X 1412.0202
#define AUTO_EXT_Y -1699.9926
#define AUTO_EXT_Z 13.5394

// INTERIOR DA PREFEITURA (Onde o chão é garantido)
#define PREF_INT_X 388.596
#define PREF_INT_Y 173.6231
#define PREF_INT_Z 1008.3828
#define PREF_INT_ID 3

// Balcão lateral (onde vai ser a Autoescola)
#define AUTO_BALCAO_X 361.5
#define AUTO_BALCAO_Y 173.5
#define AUTO_BALCAO_Z 1008.3

// Spawn do Carro de Teste (Rua)
#define SPAWN_V_X 1400.0
#define SPAWN_V_Y -1670.0
#define SPAWN_V_Z 13.5
#define SPAWN_V_A 90.0

new EmTeste[MAX_PLAYERS], CarroTeste[MAX_PLAYERS];

// Função de salvamento (Ajustada para compilar sem erros de string)
stock CNHFile(playerid, path[], size) {
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(path, size, "licencas/%s.ini", name);
}

public OnFilterScriptInit() {
    DisableInteriorEnterExits();

    // Entrada na calçada da Autoescola
    CreatePickup(1318, 1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z, 0); 
    Create3DTextLabel("{00CCFF}Autoescola 2026\n{FFFFFF}Aperte 'H' para entrar", -1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z + 0.5, 10.0, 0);

    // Saída dentro do interior (No Mundo Virtual 10)
    CreatePickup(1318, 1, PREF_INT_X, PREF_INT_Y, PREF_INT_Z, AUTO_VW_ESPECIAL);
    Create3DTextLabel("{FFFFFF}Sair da Autoescola\n{777777}Aperte 'H'", -1, PREF_INT_X, PREF_INT_Y, PREF_INT_Z + 0.5, 10.0, AUTO_VW_ESPECIAL);

    // Balcão da Autoescola (No Mundo Virtual 10)
    CreatePickup(1239, 1, AUTO_BALCAO_X, AUTO_BALCAO_Y, AUTO_BALCAO_Z, AUTO_VW_ESPECIAL);
    Create3DTextLabel("{00FF00}Atendimento Exames\n{FFFFFF}Use /exame", -1, AUTO_BALCAO_X, AUTO_BALCAO_Y, AUTO_BALCAO_Z + 0.5, 8.0, AUTO_VW_ESPECIAL);
    
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { // Tecla H
        // ENTRAR: Vai pra prefeitura, mas no mundo 10
        if(IsPlayerInRangeOfPoint(playerid, 2.0, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z)) {
            SetPlayerInterior(playerid, PREF_INT_ID);
            SetPlayerVirtualWorld(playerid, AUTO_VW_ESPECIAL);
            SetPlayerPos(playerid, PREF_INT_X, PREF_INT_Y, PREF_INT_Z);
            SendClientMessage(playerid, -1, "{00CCFF}[AUTOESCOLA] Bem-vindo à recepção!");
        }
        // SAIR: Volta pra calçada da autoescola e mundo 0
        else if(IsPlayerInRangeOfPoint(playerid, 2.0, PREF_INT_X, PREF_INT_Y, PREF_INT_Z)) {
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
            SetPlayerPos(playerid, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z);
        }
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(!strcmp(cmdtext, "/exame", true)) {
        // Só funciona se estiver no balcão da "dimensão" da autoescola
        if(GetPlayerVirtualWorld(playerid) != AUTO_VW_ESPECIAL) return 0;
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, AUTO_BALCAO_X, AUTO_BALCAO_Y, AUTO_BALCAO_Z))
            return SendClientMessage(playerid, -1, "Vá até o balcão!");
            
        ShowPlayerDialog(playerid, 888, DIALOG_STYLE_MSGBOX, "AUTOESCOLA", "Deseja pagar $3000 e iniciar o teste prático?", "Sim", "Não");
        return 1;
    }
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == 888 && response) {
        if(GetPlayerMoney(playerid) < PRECO_AUTO) return SendClientMessage(playerid, -1, "Sem grana!");
        
        GivePlayerMoney(playerid, -PRECO_AUTO);
        
        // TELEPORTE PARA A RUA (MARKET)
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z);
        
        // CRIA CARRO E COLOCA PLAYER
        CarroTeste[playerid] = CreateVehicle(466, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z, SPAWN_V_A, 1, 1, 300);
        PutPlayerInVehicle(playerid, CarroTeste[playerid], 0);
        
        SetPlayerCheckpoint(playerid, 1340.0, -1660.0, 13.5, 5.0);
        EmTeste[playerid] = 1;
        SendClientMessage(playerid, 0xFFFF00FF, "Teste iniciado! Siga o checkpoint na rua.");
    }
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    if(EmTeste[playerid]) {
        DisablePlayerCheckpoint(playerid);
        
        // Lógica de Salvamento Dini (Final Real)
        new arquivo; 
        CNHFile(playerid, arquivo, sizeof(arquivo));
        if(!dini_Exists(arquivo)) dini_Create(arquivo);
        dini_IntSet(arquivo, "Habilitado", 1);

        SendClientMessage(playerid, 0x00FF00FF, "PARABÉNS! Você passou e sua CNH foi salva.");
        DestroyVehicle(CarroTeste[playerid]);
        EmTeste[playerid] = 0;
    }
    return 1;
}
