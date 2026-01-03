#define FILTERSCRIPT
#include <a_samp>
#include <dini>
#include <float>

// --- CONFIGURAÇÕES ---
#define PRECO_MOTO      3000
#define PRECO_CARRO     7000
#define PRECO_CAMINHAO  15000

#define VEH_MOTO        461 
#define VEH_CARRO       405 
#define VEH_CAMINHAO    403 

// Coordenadas da SUA Autoescola (Rua)
#define AUTO_EXT_X 1412.0202
#define AUTO_EXT_Y -1699.9926
#define AUTO_EXT_Z 13.5394

// Coordenadas da SUA Prefeitura (Interior estável)
#define AUTO_INT_X 388.596
#define AUTO_INT_Y 173.6231
#define AUTO_INT_Z 1008.3828
#define AUTO_INT_ID 3

// Balcão de Atendimento (Mesmo da prefeitura)
#define AUTO_INFO_X 361.5
#define AUTO_INFO_Y 173.5
#define AUTO_INFO_Z 1008.3

// Spawn Veículo
#define SPAWN_V_X 1400.0
#define SPAWN_V_Y -1670.0
#define SPAWN_V_Z 13.5
#define SPAWN_V_A 90.0

new EmTeste[MAX_PLAYERS], VeiculoTeste[MAX_PLAYERS], CategoriaTeste[MAX_PLAYERS], CheckStep[MAX_PLAYERS];

stock CNHFile(playerid, path[], size) {
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(path, size, "licencas/%s.ini", name);
}

forward DescongelarPlayer(playerid);
public DescongelarPlayer(playerid) {
    TogglePlayerControllable(playerid, true);
    SetCameraBehindPlayer(playerid);
    return 1;
}

public OnFilterScriptInit() {
    DisableInteriorEnterExits();
    CreatePickup(1318, 1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z, 0); 
    Create3DTextLabel("{FFFFFF}Autoescola\n{777777}Aperte 'H' para entrar", -1, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z + 0.5, 10.0, 0);
    CreatePickup(1318, 1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z, 0);
    Create3DTextLabel("{FFFFFF}Sair\n{777777}Aperte 'H'", -1, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z + 0.5, 10.0, 0);
    CreatePickup(1239, 1, AUTO_INFO_X, AUTO_INFO_Y, AUTO_INFO_Z, 0);
    Create3DTextLabel("{00FF00}Atendimento\n{FFFFFF}Use /exame", -1, AUTO_INFO_X, AUTO_INFO_Y, AUTO_INFO_Z + 0.5, 8.0, 0);
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(newkeys & KEY_CTRL_BACK) { 
        if(IsPlayerInRangeOfPoint(playerid, 2.0, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z)) {
            TogglePlayerControllable(playerid, false);
            SetPlayerInterior(playerid, AUTO_INT_ID);
            SetPlayerPos(playerid, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z);
            SetTimerEx("DescongelarPlayer", 1000, false, "i", playerid);
        }
        else if(IsPlayerInRangeOfPoint(playerid, 2.0, AUTO_INT_X, AUTO_INT_Y, AUTO_INT_Z)) {
            TogglePlayerControllable(playerid, false);
            SetPlayerInterior(playerid, 0);
            SetPlayerPos(playerid, AUTO_EXT_X, AUTO_EXT_Y, AUTO_EXT_Z);
            SetTimerEx("DescongelarPlayer", 1000, false, "i", playerid);
        }
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(!strcmp(cmdtext, "/exame", true)) {
        if(!IsPlayerInRangeOfPoint(playerid, 4.0, AUTO_INFO_X, AUTO_INFO_Y, AUTO_INFO_Z))
            return SendClientMessage(playerid, -1, "{FF0000}Va ate o balcao!");
        ShowPlayerDialog(playerid, 9955, DIALOG_STYLE_LIST, "Autoescola", "Moto\nCarro\nCaminhao", "Iniciar", "Sair");
        return 1;
    }
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == 9955 && response) {
        new v, p;
        if(listitem == 0) { p = PRECO_MOTO; v = VEH_MOTO; CategoriaTeste[playerid] = 1; }
        else if(listitem == 1) { p = PRECO_CARRO; v = VEH_CARRO; CategoriaTeste[playerid] = 2; }
        else { p = PRECO_CAMINHAO; v = VEH_CAMINHAO; CategoriaTeste[playerid] = 3; }
        if(GetPlayerMoney(playerid) < p) return SendClientMessage(playerid, -1, "Sem dinheiro!");
        GivePlayerMoney(playerid, -p);
        SetPlayerInterior(playerid, 0);
        SetPlayerPos(playerid, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z);
        EmTeste[playerid] = 1; CheckStep[playerid] = 0;
        VeiculoTeste[playerid] = CreateVehicle(v, SPAWN_V_X, SPAWN_V_Y, SPAWN_V_Z, SPAWN_V_A, 1, 1, 300);
        SetTimerEx("NoCarro", 1000, false, "ii", playerid, VeiculoTeste[playerid]);
        SetPlayerCheckpoint(playerid, 1340.0, -1660.0, 13.5, 5.0);
    }
    return 1;
}

forward NoCarro(playerid, v);
public NoCarro(playerid, v) { PutPlayerInVehicle(playerid, v, 0); return 1; }

stock FinalizarTeste(playerid, bool:aprovado) {
    DisablePlayerCheckpoint(playerid);
    if(VeiculoTeste[playerid] != -1) DestroyVehicle(VeiculoTeste[playerid]);
    VeiculoTeste[playerid] = -1; EmTeste[playerid] = 0;
    if(aprovado) {
        new f[64]; CNHFile(playerid, f, sizeof(f));
        if(!dini_Exists(f)) dini_Create(f);
        if(CategoriaTeste[playerid] == 1) dini_IntSet(f, "Moto", 1);
        else if(CategoriaTeste[playerid] == 2) dini_IntSet(f, "Carro", 1);
        else dini_IntSet(f, "Caminhao", 1);
        SendClientMessage(playerid, 0x00FF00FF, "Aprovado!");
    }
    return 1;
}
