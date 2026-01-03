#define FILTERSCRIPT
#include <a_samp>
#include <dini> // Certifique-se de ter o plugin dini

// Configurações
#define PREF_EXT_X 1481.0
#define PREF_EXT_Y -1741.0
#define PREF_EXT_Z 13.5
#define PREF_INT_X 384.8
#define PREF_INT_Y 173.8
#define PREF_INT_Z 1008.3
#define PREF_INT_ID 3

new PlayerJob[MAX_PLAYERS];

// Nomes dos empregos
new const JobNames[][] = {
    "Desempregado",
    "Motorista de Onibus",
    "Gari",
    "Entregador de Pizza",
    "Taxista"
};

// Caminho do arquivo de salvamento
stock JobFile(playerid) {
    new name[MAX_PLAYER_NAME], str[64];
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), "empregos/%s.ini", name);
    return str;
}

public OnFilterScriptInit() {
    // Pickups e Textos
    CreatePickup(1318, 1, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z, -1); 
    Create3DTextLabel("{FFFF00}Prefeitura de LS\n{FFFFFF}Aperte 'H' para entrar", -1, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z, 15.0, 0);

    CreatePickup(1318, 1, PREF_INT_X, PREF_INT_Y, PREF_INT_Z, -1);
    Create3DTextLabel("{FFFF00}Sair\n{FFFFFF}Aperte 'H'", -1, PREF_INT_X, PREF_INT_Y, PREF_INT_Z, 10.0, 0);
    
    print(">> [SISTEMA EMPREGOS 2026] Carregado com Salvamento.");
    return 1;
}

// Carregar emprego quando o player conectar
public OnPlayerConnect(playerid) {
    if(dini_Exists(JobFile(playerid))) {
        PlayerJob[playerid] = dini_Int(JobFile(playerid), "EmpregoID");
    } else {
        PlayerJob[playerid] = 0;
    }
    return 1;
}

// Salvar emprego quando o player sair
public OnPlayerDisconnect(playerid, reason) {
    new file[64];
    format(file, sizeof(file), "%s", JobFile(playerid));
    if(!dini_Exists(file)) dini_Create(file);
    dini_IntSet(file, "EmpregoID", PlayerJob[playerid]);
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { // Tecla H
        if(IsPlayerInRangeOfPoint(playerid, 2.5, PREF_EXT_X, PREF_EXT_Y, PREF_EXT_Z)) {
            SetPlayerPos(playerid, PREF_INT_X, PREF_INT_Y, PREF_INT_Z);
            SetPlayerInterior(playerid, PREF_INT_ID);
            SendClientMessage(playerid, 0x00FF00FF, "Bem-vindo a Prefeitura! Use /empregos.");
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
        if(!IsPlayerInRangeOfPoint(playerid, 15.0, PREF_INT_X, PREF_INT_Y, PREF_INT_Z))
            return SendClientMessage(playerid, -1, "Va ate a Prefeitura para ver os empregos.");

        ShowPlayerDialog(playerid, 888, DIALOG_STYLE_LIST, "Vagas em LS", "Motorista de Onibus\nGari\nEntregador de Pizza\nTaxista", "Pegar", "Sair");
        return 1;
    }

    if(!strcmp(cmdtext, "/sairemprego", true)) {
        PlayerJob[playerid] = 0;
        SendClientMessage(playerid, 0xFFFF00FF, "Voce pediu demissao.");
        return 1;
    }
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == 888 && response) {
        PlayerJob[playerid] = listitem + 1;
        new str[64];
        format(str, sizeof(str), "Agora voce e: %s", JobNames[PlayerJob[playerid]]);
        SendClientMessage(playerid, 0x00FF00FF, str);
    }
    return 1;
}
