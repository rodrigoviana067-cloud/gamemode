#define FILTERSCRIPT
#include <a_samp>

// --- COORDENADAS AJUSTADAS ---
// Porta de Fora (Movido da calçada para a parede da prefeitura)
#define PREF_EXT_X 1481.0
#define PREF_EXT_Y -1744.4 // Ajustado para encostar na porta
#define PREF_EXT_Z 13.5

// Porta de Dentro (Ajustado para o player não nascer dentro da porta)
#define PREF_INT_X 384.8
#define PREF_INT_Y 176.2 // Ajustado para frente da porta interna
#define PREF_INT_Z 1008.3
#define PREF_INT_ID 3

// Balcão de Empregos (Ajustado para fora da bancada)
#define JOB_INFO_X 361.5
#define JOB_INFO_Y 173.5
#define JOB_INFO_Z 1008.3

public OnFilterScriptInit() {
    // ENTRADA (Seta Branca colada na porta de fora)
    CreatePickup(1318, 1, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z, -1); 
    Create3DTextLabel("{FFFFFF}Prefeitura\n{777777}Aperte 'H' para entrar", -1, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z + 0.5, 10.0, 0);

    // SAÍDA (Seta Branca colada na porta de dentro)
    CreatePickup(1318, 1, PREF_INT_X, PREF_INT_Y, PREF_INT_Z, -1);
    Create3DTextLabel("{FFFFFF}Sair\n{777777}Aperte 'H'", -1, PREF_INT_X, PREF_INT_Y, PREF_INT_Z + 0.5, 10.0, 0);

    // BALCÃO (Ícone 'i' centralizado no salão)
    CreatePickup(1239, 1, JOB_INFO_X, JOB_INFO_Y, JOB_INFO_Z, -1);
    Create3DTextLabel("{00FF00}Central de Vagas\n{FFFFFF}Use /vagas", -1, JOB_INFO_X, JOB_INFO_Y, JOB_INFO_Z + 0.5, 8.0, 0);
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { // Tecla H
        if(IsPlayerInRangeOfPoint(playerid, 2.0, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z)) {
            SetPlayerPos(playerid, PREF_INT_X, PREF_INT_Y, PREF_INT_Z);
            SetPlayerInterior(playerid, PREF_INT_ID);
        }
        else if(IsPlayerInRangeOfPoint(playerid, 2.0, PREF_INT_X, PREF_INT_Y, PREF_INT_Z)) {
            SetPlayerPos(playerid, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z);
            SetPlayerInterior(playerid, 0);
        }
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(!strcmp(cmdtext, "/vagas", true)) {
        if(!IsPlayerInRangeOfPoint(playerid, 4.0, JOB_INFO_X, JOB_INFO_Y, JOB_INFO_Z))
            return SendClientMessage(playerid, -1, "{FF0000}Va ate o balcao de informacoes.");

        ShowPlayerDialog(playerid, 777, DIALOG_STYLE_LIST, "Vagas em LS (GPS)", 
        "Motorista de Onibus\nGari\nEntregador de Pizza\nTaxista", "Marcar", "Fechar");
        return 1;
    }
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == 777 && response) {
        DisablePlayerCheckpoint(playerid); 
        switch(listitem) {
            case 0: SetPlayerCheckpoint(playerid, 1754.0, -1901.0, 13.5, 5.0);
            case 1: SetPlayerCheckpoint(playerid, 2187.0, -1972.0, 13.5, 5.0);
            case 2: SetPlayerCheckpoint(playerid, 2101.0, -1805.0, 13.5, 5.0);
            case 3: SetPlayerCheckpoint(playerid, 1740.0, -1861.0, 13.5, 5.0);
        }
        SendClientMessage(playerid, 0x00FF00FF, "[GPS] Local marcado no seu mapa!");
    }
    return 1;
}
