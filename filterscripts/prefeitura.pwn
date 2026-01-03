#define FILTERSCRIPT
#include <a_samp>
#include <dini>

// Coordenadas da Porta (Lado de Fora) - Ajustado para a Calçada
#define PREF_EXT_X 1481.1
#define PREF_EXT_Y -1741.0
#define PREF_EXT_Z 13.5

// Coordenadas do Interior (Lado de Dentro)
#define PREF_INT_X 384.8
#define PREF_INT_Y 173.8
#define PREF_INT_Z 1008.3
#define PREF_INT_ID 3

// Balcão de Informações (Frente à bancada, não dentro)
#define JOB_INFO_X 361.5
#define JOB_INFO_Y 173.5
#define JOB_INFO_Z 1008.3

public OnFilterScriptInit() {
    // ENTRADA (Seta Branca na Porta)
    CreatePickup(1318, 1, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z, -1); 
    Create3DTextLabel("{FFFFFF}Prefeitura\n{777777}Aperte 'H' para entrar", -1, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z, 10.0, 0);

    // SAÍDA (Seta Branca no Interior)
    CreatePickup(1318, 1, PREF_INT_X, PREF_INT_Y, PREF_INT_Z, -1);
    Create3DTextLabel("{FFFFFF}Sair\n{777777}Aperte 'H'", -1, PREF_INT_X, PREF_INT_Y, PREF_INT_Z, 10.0, 0);

    // BALCÃO DE EMPREGOS (Ícone de Informação 'i')
    CreatePickup(1239, 1, JOB_INFO_X, JOB_INFO_Y, JOB_INFO_Z, -1);
    Create3DTextLabel("{00FF00}Central de Vagas\n{FFFFFF}Use /vagas para marcar no mapa", -1, JOB_INFO_X, JOB_INFO_Y, JOB_INFO_Z, 8.0, 0);
    
    print(">> [PREFEITURA 2026] Sistema de Marcacao Ativo.");
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
            return SendClientMessage(playerid, -1, "{FF0000}[ERRO] Voce deve estar no balcao da prefeitura!");

        ShowPlayerDialog(playerid, 777, DIALOG_STYLE_LIST, "Vagas Disponiveis em LS", 
        "Motorista de Onibus (Agencia)\nGari (Deposito)\nEntregador de Pizza (Pizzaria)\nTaxista (Central)", 
        "Marcar", "Fechar");
        return 1;
    }
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == 777 && response) {
        DisablePlayerCheckpoint(playerid); // Limpa marcação anterior
        
        switch(listitem) {
            case 0: { // Ônibus
                SetPlayerCheckpoint(playerid, 1754.0, -1901.0, 13.5, 5.0);
                SendClientMessage(playerid, 0x00FF00FF, "[GPS] Agencia de Onibus marcada no mapa!");
            }
            case 1: { // Gari
                SetPlayerCheckpoint(playerid, 2187.0, -1972.0, 13.5, 5.0);
                SendClientMessage(playerid, 0x00FF00FF, "[GPS] Deposito de Lixo marcado no mapa!");
            }
            case 2: { // Pizza
                SetPlayerCheckpoint(playerid, 2101.0, -1805.0, 13.5, 5.0);
                SendClientMessage(playerid, 0x00FF00FF, "[GPS] Pizzaria de LS marcada no mapa!");
            }
            case 3: { // Taxi
                SetPlayerCheckpoint(playerid, 1740.0, -1861.0, 13.5, 5.0);
                SendClientMessage(playerid, 0x00FF00FF, "[GPS] Central de Taxi marcada no mapa!");
            }
        }
        SendClientMessage(playerid, -1, "Siga o Checkpoint vermelho no seu minimapa.");
    }
    return 1;
}
