#define FILTERSCRIPT
#include <a_samp>

// --- COORDENADAS AJUSTADAS 2026 ---
// Porta de Fora (Exatamente na coordenada que você passou)
#define PREF_EXT_X 1481.2259
#define PREF_EXT_Y -1771.4321
#define PREF_EXT_Z 13.5469 // Ajustado para o chão
#define PREF_EXT_A 357.2106

// Porta de Dentro (Interior da Prefeitura)
#define PREF_INT_X 384.8
#define PREF_INT_Y 176.2 
#define PREF_INT_Z 1008.3
#define PREF_INT_ID 3

// Balcão de Empregos (Local para usar o comando)
#define JOB_INFO_X 361.5
#define JOB_INFO_Y 173.5
#define JOB_INFO_Z 1008.3

public OnFilterScriptInit() {
    // ENTRADA: Apenas Seta Branca (1318) na porta nova
    CreatePickup(1318, 1, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z, -1); 
    Create3DTextLabel("{FFFFFF}Prefeitura\n{777777}Aperte 'H' para entrar", -1, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z + 0.5, 10.0, 0);

    // SAÍDA: Apenas Seta Branca (1318) no interior
    CreatePickup(1318, 1, PREF_INT_X, PREF_INT_Y, PREF_INT_Z, -1);
    Create3DTextLabel("{FFFFFF}Sair\n{777777}Aperte 'H'", -1, PREF_INT_X, PREF_INT_Y, PREF_INT_Z + 0.5, 10.0, 0);

    // BALCÃO: Ícone de Informação (1239) para marcar empregos
    CreatePickup(1239, 1, JOB_INFO_X, JOB_INFO_Y, JOB_INFO_Z, -1);
    Create3DTextLabel("{00FF00}Central de Empregos\n{FFFFFF}Use /empregos para marcar", -1, JOB_INFO_X, JOB_INFO_Y, JOB_INFO_Z + 0.5, 8.0, 0);
    
    print(">> [PREFEITURA 2026] Revisada com Sucesso.");
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { // Tecla H
        // Teleporte para dentro
        if(IsPlayerInRangeOfPoint(playerid, 2.0, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z)) {
            SetPlayerPos(playerid, PREF_INT_X, PREF_INT_Y, PREF_INT_Z);
            SetPlayerInterior(playerid, PREF_INT_ID);
        }
        // Teleporte para fora
        else if(IsPlayerInRangeOfPoint(playerid, 2.0, PREF_INT_X, PREF_INT_Y, PREF_INT_Z)) {
            SetPlayerPos(playerid, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z);
            SetPlayerInterior(playerid, 0);
        }
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    // Comando alterado para /empregos conforme solicitado
    if(!strcmp(cmdtext, "/empregos", true)) {
        if(!IsPlayerInRangeOfPoint(playerid, 4.0, JOB_INFO_X, JOB_INFO_Y, JOB_INFO_Z))
            return SendClientMessage(playerid, -1, "{FF0000}[ERRO] Voce deve estar no balcao de informacoes!");

        ShowPlayerDialog(playerid, 777, DIALOG_STYLE_LIST, "Vagas disponiveis (Marcar GPS)", 
        "Motorista de Onibus\nGari\nEntregador de Pizza\nTaxista", "Marcar", "Fechar");
        return 1;
    }
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == 777 && response) {
        DisablePlayerCheckpoint(playerid); // Remove marcação anterior
        
        switch(listitem) {
            case 0: SetPlayerCheckpoint(playerid, 1754.0, -1901.0, 13.5, 5.0); // Onibus
            case 1: SetPlayerCheckpoint(playerid, 2187.0, -1972.0, 13.5, 5.0); // Gari
            case 2: SetPlayerCheckpoint(playerid, 2101.0, -1805.0, 13.5, 5.0); // Pizza
            case 3: SetPlayerCheckpoint(playerid, 1740.0, -1861.0, 13.5, 5.0); // Taxi
        }
        SendClientMessage(playerid, 0x00FF00FF, "[GPS] O local do emprego foi marcado no seu mapa!");
    }
    return 1;
}
