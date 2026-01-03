#define FILTERSCRIPT
#include <a_samp>
#include <dini>
#include <float>

// --- CONFIGURAÇÕES ---
#define AUTO_INT_ID     3
#define AUTO_VW         10 // Mundo virtual para evitar conflitos

// Coordenadas corrigidas para evitar queda
#define AUTO_EXT_X 1411.5690
#define AUTO_EXT_Y -1699.5178
#define AUTO_EXT_Z 13.5394

#define AUTO_INT_X 2033.4274
#define AUTO_INT_Y 117.3727
#define AUTO_INT_Z 1035.3000 

// --- VARIÁVEIS ---
new EmTeste[MAX_PLAYERS], VeiculoTeste[MAX_PLAYERS], CategoriaTeste[MAX_PLAYERS], CheckStep[MAX_PLAYERS];

public OnFilterScriptInit() {
    DisableInteriorEnterExits();
    // Pickups
    CreatePickup(1318, 1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z, 0); // Mundo 0 (Rua)
    CreatePickup(1318, 1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z, AUTO_VW); // Mundo 10 (Interior)
    
    Create3DTextLabel("{00FF00}Autoescola\n{FFFFFF}Pressione 'H' para entrar", -1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z + 0.5, 10.0, 0);
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { // Tecla H
        // ENTRAR NA AUTOESCOLA
        if(IsPlayerInRangeOfPoint(playerid, 3.0, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z)) {
            TogglePlayerControllable(playerid, false); // Congela para carregar mapa
            SetPlayerInterior(playerid, AUTO_INT_ID);
            SetPlayerVirtualWorld(playerid, AUTO_VW);
            SetPlayerPos(playerid, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z);
            
            // Timer curto para garantir que o chão carregou
            SetTimerEx("DescongelarPlayer", 1000, false, "i", playerid);
            return 1;
        }
        
        // SAIR DA AUTOESCOLA
        if(IsPlayerInRangeOfPoint(playerid, 3.0, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z)) {
            TogglePlayerControllable(playerid, false);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
            SetPlayerPos(playerid, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z);
            
            SetTimerEx("DescongelarPlayer", 1000, false, "i", playerid);
            return 1;
        }
    }
    return 1;
}

forward DescongelarPlayer(playerid);
public DescongelarPlayer(playerid) {
    TogglePlayerControllable(playerid, true);
    // Forçar o streaming dos objetos ao redor
    SetCameraBehindPlayer(playerid); 
    return 1;
}

// No OnDialogResponse, certifique-se de resetar o Virtual World ao iniciar o teste
// para o player conseguir ver o carro na rua:
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == 9955 && response) {
        // ... (seu código de preço e modelo)
        
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0); // VOLTA PARA O MUNDO 0 (RUA)
        
        EmTeste[playerid] = 1;
        VeiculoTeste[playerid] = CreateVehicle(vModel, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z, SPAWN_V_A, 1, 1, 300);
        
        // Coloca no carro após um pequeno delay para evitar bugs de posição
        SetTimerEx("ColocarNoCarro", 500, false, "ii", playerid, VeiculoTeste[playerid]);
    }
    return 1;
}

forward ColocarNoCarro(playerid, veiculo);
public ColocarNoCarro(playerid, veiculo) {
    PutPlayerInVehicle(playerid, veiculo, 0);
    return 1;
}
