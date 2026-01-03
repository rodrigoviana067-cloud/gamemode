#define FILTERSCRIPT
#include <a_samp>
#include <dini>

// Configurações de Posição
#define PREF_EXT_X 1481.0
#define PREF_EXT_Y -1741.0
#define PREF_EXT_Z 13.5

#define PREF_INT_X 384.8
#define PREF_INT_Y 173.8
#define PREF_INT_Z 1008.3
#define PREF_INT_ID 3

// Local do Balcão de Empregos (Dentro da Prefeitura)
#define JOB_MARKER_X 360.0
#define JOB_MARKER_Y 173.0
#define JOB_MARKER_Z 1008.3

new PlayerJob[MAX_PLAYERS];

new const JobNames[][] = {
    "Desempregado",
    "Motorista de Onibus",
    "Gari",
    "Entregador de Pizza",
    "Taxista"
};

stock JobFile(playerid) {
    new name[MAX_PLAYER_NAME], str[64];
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), "empregos/%s.ini", name);
    return str;
}

public OnFilterScriptInit() {
    // ENTRADA (Seta Branca)
    CreatePickup(1318, 1, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z, -1); 
    Create3DTextLabel("{FFFFFF}Prefeitura de LS\n{777777}Aperte 'H' para entrar", -1, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z, 10.0, 0);

    // SAÍDA (Seta Branca)
    CreatePickup(1318, 1, PREF_INT_X, PREF_INT_Y, PREF_INT_Z, -1);
    Create3DTextLabel("{FFFFFF}Sair\n{777777}Aperte 'H'", -1, PREF_INT_X, PREF_INT_Y, PREF_INT_Z, 10.0, 0);

    // BALCÃO DE EMPREGOS (Pickup de Informação i)
    CreatePickup(1239, 1, JOB_MARKER_X, JOB_MARKER_Y, JOB_MARKER_Z, -1);
    Create3DTextLabel("{00FF00}Centro de Empregos\n{FFFFFF}Use /empregos aqui", -1, JOB_MARKER_X, JOB_MARKER_Y, JOB_MARKER_Z, 10.0, 0);
    
    print(">> [SISTEMA PREFEITURA 2026] Atualizado com Balcao de Empregos.");
    return 1;
}

public OnPlayerConnect(playerid) {
    if(dini_Exists(JobFile(playerid))) PlayerJob[playerid] = dini_Int(JobFile(playerid), "EmpregoID");
    else PlayerJob[playerid] = 0;
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    new file[64]; format(file, sizeof(file), "%s", JobFile(playerid));
    if(!dini_Exists(file)) dini_Create(file);
    dini_IntSet(file, "EmpregoID", PlayerJob[playerid]);
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { // Tecla H
        if(IsPlayerInRangeOfPoint(playerid, 2.5, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z)) {
            SetPlayerPos(playerid, PREF_INT_X, PREF_INT_Y, PREF_INT_Z);
            SetPlayerInterior(playerid, PREF_INT_ID);
        }
        else if(IsPlayerInRangeOfPoint(playerid, 2.5, PREF_INT_X, PREF_INT_Y, PREF_INT_Z)) {
            SetPlayerPos(playerid, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z);
            SetPlayerInterior(playerid, 0);
        }
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(!strcmp(cmdtext, "/empregos", true)) {
        // Verifica se está no balcão de empregos e não apenas "dentro da prefeitura"
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, JOB_MARKER_X, JOB_MARKER_Y, JOB_MARKER_Z))
            return SendClientMessage(playerid, -1, "{FF0000}[ERRO] Voce deve ir ate o balcao do Centro de Empregos!");

        ShowPlayerDialog(playerid, 888, DIALOG_STYLE_LIST, "Centro de Empregos LS", "Motorista de Onibus\nGari\nEntregador de Pizza\nTaxista\n{FF0000}Pedir Demissao", "Selecionar", "Fechar");
        return 1;
    }
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == 888 && response) {
        if(listitem == 4) { // Clicou em Pedir Demissão
            PlayerJob[playerid] = 0;
            SendClientMessage(playerid, 0xFF0000FF, "Voce pediu demissao e agora esta desempregado.");
        } else {
            PlayerJob[playerid] = listitem + 1;
            new str[64];
            format(str, sizeof(str), "{00FF00}Voce agora trabalha como: %s", JobNames[PlayerJob[playerid]]);
            SendClientMessage(playerid, -1, str);
        }
    }
    return 1;
}
