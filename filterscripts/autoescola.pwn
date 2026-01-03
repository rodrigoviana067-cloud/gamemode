#define FILTERSCRIPT
#include <a_samp>
#include <dini>

// --- CONFIGURAÇÕES AUTOESCOLA 2026 ---
#define PRECO_AUTO      3000
#define AUTO_VW_ESPECIAL 10 

// Calçada da Autoescola (Market)
#define AUTO_EXT_X 1412.0202
#define AUTO_EXT_Y -1699.9926
#define AUTO_EXT_Z 13.5394

// INTERIOR DA PREFEITURA
#define PREF_INT_X 388.596
#define PREF_INT_Y 173.6231
#define PREF_INT_Z 1008.3828
#define PREF_INT_ID 3

// Balcão lateral
#define AUTO_BALCAO_X 361.5
#define AUTO_BALCAO_Y 173.5
#define AUTO_BALCAO_Z 1008.3

// Spawn do Carro de Teste
#define SPAWN_V_X 1400.0
#define SPAWN_V_Y -1670.0
#define SPAWN_V_Z 13.5
#define SPAWN_V_A 90.0

new EmTeste[MAX_PLAYERS], CarroTeste[MAX_PLAYERS];

// CORREÇÃO: Adicionado 'const' para evitar Warning 239
stock CNHFile(playerid, path[], size) {
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(path, size, "licencas/%s.ini", name);
}

public OnFilterScriptInit() {
    // Pickups e Textos (Adicionado const internamente pelo compilador ao usar strings diretas)
    CreatePickup(1318, 1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z, 0); 
    Create3DTextLabel("Autoescola 2026\nAperte 'H' para entrar", -1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z + 0.5, 10.0, 0);

    CreatePickup(1318, 1, PREF_INT_X, PREF_INT_Y, PREF_INT_Z, AUTO_VW_ESPECIAL);
    Create3DTextLabel("Sair da Autoescola\nAperte 'H'", -1, PREF_INT_X, PREF_INT_Y, PREF_INT_Z + 0.5, 10.0, AUTO_VW_ESPECIAL);

    CreatePickup(1239, 1, AUTO_BALCAO_X, AUTO_BALCAO_Y, AUTO_BALCAO_Z, AUTO_VW_ESPECIAL);
    Create3DTextLabel("Atendimento Exames\nUse /exame", -1, AUTO_BALCAO_X, AUTO_BALCAO_Y, AUTO_BALCAO_Z + 0.5, 8.0, AUTO_VW_ESPECIAL);
    
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { 
        if(IsPlayerInRangeOfPoint(playerid, 2.0, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z)) {
            SetPlayerInterior(playerid, PREF_INT_ID);
            SetPlayerVirtualWorld(playerid, AUTO_VW_ESPECIAL);
            SetPlayerPos(playerid, PREF_INT_X, PREF_INT_Y, PREF_INT_Z);
            SendClientMessage(playerid, -1, "{00CCFF}[AUTOESCOLA] Bem-vindo à recepção!");
        }
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
        
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z);
        
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
        
        // CORREÇÃO: 'arquivo' agora é uma string (array), não um inteiro
        new arquivo[64]; 
        CNHFile(playerid, arquivo, sizeof(arquivo));
        
        if(!dini_Exists(arquivo)) dini_Create(arquivo);
        dini_IntSet(arquivo, "Habilitado", 1);

        SendClientMessage(playerid, 0x00FF00FF, "PARABÉNS! Você passou e sua CNH foi salva.");
        
        if(IsPlayerInAnyVehicle(playerid)) {
            DestroyVehicle(CarroTeste[playerid]);
        }
        EmTeste[playerid] = 0;
    }
    return 1;
}
