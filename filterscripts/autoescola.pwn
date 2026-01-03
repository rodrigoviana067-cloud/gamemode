#define FILTERSCRIPT
#include <a_samp>
#include <float>

// --- CONFIGURAÇÕES AUTOESCOLA 2026 ---
#define DIALOG_AUTOESCOLA 2200

// Coordenadas da SUA Calçada
#define AUTO_EXT_X 1412.0202
#define AUTO_EXT_Y -1699.9926
#define AUTO_EXT_Z 13.5394

// Interior Oficial (ID 3) - Ajustado para não cair
#define AUTO_INT_X 2046.0
#define AUTO_INT_Y 155.0
#define AUTO_INT_Z 1060.98
#define AUTO_INT_ID 3

// Spawn do Carro de Teste (Rua)
#define SPAWN_CAR_X 1400.0
#define SPAWN_CAR_Y -1670.0
#define SPAWN_CAR_Z 13.5
#define SPAWN_CAR_A 90.0

new InAutoEscola[MAX_PLAYERS];
new carroauto[MAX_PLAYERS];
new ponto[MAX_PLAYERS];

// Pontos do Percurso (Ajustados para Market/LS perto da sua autoescola)
new Float:AutoPoints[8][3] = {
    {1340.0, -1660.0, 13.5},
    {1280.0, -1640.0, 13.5},
    {1200.0, -1700.0, 13.5},
    {1200.0, -1800.0, 13.5},
    {1300.0, -1850.0, 13.5},
    {1400.0, -1800.0, 13.5},
    {1450.0, -1700.0, 13.5},
    {1412.0, -1700.0, 13.5}
};

public OnFilterScriptInit() {
    DisableInteriorEnterExits();
    // Pickup de Entrada
    CreatePickup(1318, 1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z, 0); 
    Create3DTextLabel("{FFFFFF}Autoescola\n{FFFF00}Aperte 'H' para entrar", -1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z + 0.5, 10.0, 0);
    
    // Pickup de Saída (Dentro)
    CreatePickup(1318, 1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z, 0);
    
    // Balcão de Teste (Dentro)
    CreatePickup(1239, 1, 2043.0, 162.0, 1060.98, 0);
    Create3DTextLabel("{00FF00}Iniciar Exame\n{FFFFFF}Aperte 'F' no balcão", -1, 2043.0, 162.0, 1060.98 + 0.5, 8.0, 0);
    
    print(">> Sistema Autoescola 2026 Carregado.");
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    // Tecla H - Entrar e Sair
    if(newkeys & KEY_CTRL_BACK) {
        if(IsPlayerInRangeOfPoint(playerid, 2.0, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z)) {
            TogglePlayerControllable(playerid, false);
            SetPlayerInterior(playerid, AUTO_INT_ID);
            SetPlayerPos(playerid, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z);
            SetTimerEx("LiberarPlayer", 2000, false, "i", playerid);
        }
        else if(IsPlayerInRangeOfPoint(playerid, 2.0, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z)) {
            TogglePlayerControllable(playerid, false);
            SetPlayerInterior(playerid, 0);
            SetPlayerPos(playerid, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z);
            SetTimerEx("LiberarPlayer", 1000, false, "i", playerid);
        }
    }
    // Tecla F - Iniciar Exame no Balcão
    if(newkeys & KEY_SECONDARY_ATTACK) {
        if(IsPlayerInRangeOfPoint(playerid, 2.0, 2043.0, 162.0, 1060.98)) {
            ShowPlayerDialog(playerid, DIALOG_AUTOESCOLA, DIALOG_STYLE_MSGBOX, "AUTO ESCOLA", "Deseja pagar $200 e iniciar o teste prático?", "Sim", "Não");
        }
    }
    return 1;
}

forward LiberarPlayer(playerid);
public LiberarPlayer(playerid) {
    TogglePlayerControllable(playerid, true);
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == DIALOG_AUTOESCOLA) {
        if(response) {
            if(GetPlayerMoney(playerid) < 200) return SendClientMessage(playerid, -1, "Você não tem $200.");
            
            GivePlayerMoney(playerid, -200);
            InAutoEscola[playerid] = 1;
            ponto[playerid] = 0;

            SetPlayerInterior(playerid, 0);
            SetPlayerPos(playerid, SPAWN_CAR_X, SPAWN_CAR_Y, SPAWN_CAR_Z);
            
            carroauto[playerid] = CreateVehicle(466, SPAWN_CAR_X, SPAWN_CAR_Y, SPAWN_CAR_Z, SPAWN_CAR_A, 1, 1, -1);
            PutPlayerInVehicle(playerid, carroauto[playerid], 0);
            
            SetPlayerRaceCheckpoint(playerid, 0, AutoPoints[0][0], AutoPoints[0][1], AutoPoints[0][2], AutoPoints[1][0], AutoPoints[1][1], AutoPoints[1][2], 5.0);
            SendClientMessage(playerid, -1, "(AUTO ESCOLA) Siga os checkpoints com cuidado!");
        }
    }
    return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid) {
    if(InAutoEscola[playerid] == 1) {
        ponto[playerid]++;
        
        if(ponto[playerid] < 7) {
            new p = ponto[playerid];
            SetPlayerRaceCheckpoint(playerid, 0, AutoPoints[p][0], AutoPoints[p][1], AutoPoints[p][2], AutoPoints[p+1][0], AutoPoints[p+1][1], AutoPoints[p+1][2], 5.0);
        }
        else if(ponto[playerid] == 7) {
            SetPlayerRaceCheckpoint(playerid, 1, AutoPoints[7][0], AutoPoints[7][1], AutoPoints[7][2], 0.0, 0.0, 0.0, 5.0);
        }
        else { // Fim do teste
            DisablePlayerRaceCheckpoint(playerid);
            SendClientMessage(playerid, 0x00FF00FF, "PARABÉNS! Você passou no teste da Autoescola.");
            DestroyVehicle(carroauto[playerid]);
            InAutoEscola[playerid] = 0;
            // Aqui você daria a carteira (ex: PlayerInfo[playerid][pCarteira] = 1;)
        }
    }
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
    if(InAutoEscola[playerid] == 1 && vehicleid == carroauto[playerid]) {
        DestroyVehicle(carroauto[playerid]);
        InAutoEscola[playerid] = 0;
        DisablePlayerRaceCheckpoint(playerid);
        SendClientMessage(playerid, 0xFF0000FF, "Você saiu do carro e foi REPROVADO!");
    }
    return 1;
}
