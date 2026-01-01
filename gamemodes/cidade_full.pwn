/*
    GAMEMODE: CIDADE FULL 2026 - VERSÃO PICKUP BIKE
    Sistemas: Login, Banco, GPS, Empregos e Pickup de Bikes Anti-Poluição.
*/

#include <a_samp>
#include <zcmd>
#include <dini>

// IDs de Diálogos
#define DIALOG_LOGIN        1
#define DIALOG_REGISTER     2
#define DIALOG_GPS_MENU     500
#define DIALOG_BANK_MENU    600
#define DIALOG_LISTA_EMPREGOS 800

// Variáveis Globais
new bool:Logado[MAX_PLAYERS];
new PlayerMoney[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];
new BikeNovato[MAX_PLAYERS]; // Armazena o ID da bike criada
new PickupBike; // Variável do Pickup

// --- Funções Auxiliares ---

stock GetConta(playerid) {
    new str[64], name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), "contas/%s.ini", name);
    return str;
}

forward MostrarLogin(playerid);
public MostrarLogin(playerid) {
    if (dini_Exists(GetConta(playerid))) {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{00CCFF}Login", "Digite sua senha:", "Entrar", "Sair");
    } else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{00CCFF}Registro", "Crie sua senha:", "Registrar", "Sair");
    }
}

main() { print("Cidade Full 2026 - Pickup de Bikes Ativo"); }

public OnGameModeInit() {
    SetGameModeText("Cidade Full v2.0");
    AddPlayerClass(26, 1958.37, -2173.0, 13.5, 180.0, 0, 0, 0, 0, 0, 0);
    
    // Pickups
    CreatePickup(1274, 1, 1467.0, -1010.0, 26.0, -1); // Banco LS
    
    // PICKUP DE BIKES NO AEROPORTO (ID 1239 - Ícone de Informação)
    PickupBike = CreatePickup(1239, 1, 1958.37, -2173.0, 13.5, -1); 
    
    // Criar Texto em cima do Pickup
    Create3DTextLabel("{FFFF00}Pegar Bike de Novato\n{FFFFFF}Pise aqui", 0xFFFFFFFF, 1958.37, -2173.0, 14.0, 10.0, 0, 0);
    return 1;
}

public OnPlayerConnect(playerid) {
    Logado[playerid] = false;
    BikeNovato[playerid] = -1; // -1 significa que ele não tem bike
    SetTimerEx("MostrarLogin", 1500, false, "i", playerid);
    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid) {
    if(!Logado[playerid]) return 1;

    // Lógica do Pickup de Bike
    if(pickupid == PickupBike) {
        if(BikeNovato[playerid] != -1) {
            DestroyVehicle(BikeNovato[playerid]); // Destrói a anterior se existir
        }
        
        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
        
        BikeNovato[playerid] = CreateVehicle(510, x, y, z, a, 1, 1, 60); // Cria Mountain Bike
        PutPlayerInVehicle(playerid, BikeNovato[playerid], 0);
        
        SendClientMessage(playerid, -1, "{00FF00}Bike entregue! {FFFFFF}Ela sumirá se você descer dela.");
    }
    return 1;
}

// --- SISTEMA ANTI-POLUIÇÃO (Remove a bike ao descer) ---
public OnPlayerStateChange(playerid, newstate, oldstate) {
    if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT) {
        new vehid = GetPlayerVehicleID(playerid);
        // Se o veículo que ele desceu for a bike que ele pegou no pickup
        if(BikeNovato[playerid] != -1) {
            DestroyVehicle(BikeNovato[playerid]);
            BikeNovato[playerid] = -1;
            SendClientMessage(playerid, -1, "{FF0000}[Cidade Full]{FFFFFF} Bike removida para evitar poluição na cidade.");
        }
    }
    return 1;
}

public OnPlayerSpawn(playerid) {
    if(!Logado[playerid]) return Kick(playerid);
    SetPlayerPos(playerid, 1958.37, -2173.0, 13.5); // Spawn Aeroporto
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    if(BikeNovato[playerid] != -1) DestroyVehicle(BikeNovato[playerid]);
    
    if(Logado[playerid]) {
        new path[64]; format(path, sizeof(path), GetConta(playerid));
        dini_IntSet(path, "DinheiroBanco", PlayerMoney[playerid]);
        dini_IntSet(path, "Emprego", PlayerEmprego[playerid]);
    }
    return 1;
}

// Comandos e Diálogos (Login/Registro/Banco)
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == DIALOG_REGISTER) {
        if(!response) return Kick(playerid);
        dini_Create(GetConta(playerid));
        dini_Set(GetConta(playerid), "Senha", inputtext);
        dini_IntSet(GetConta(playerid), "DinheiroBanco", 1000);
        Logado[playerid] = true;
        SpawnPlayer(playerid);
        return 1;
    }
    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        if(!strcmp(inputtext, dini_Get(GetConta(playerid), "Senha"))) {
            PlayerMoney[playerid] = dini_Int(GetConta(playerid), "DinheiroBanco");
            Logado[playerid] = true;
            SpawnPlayer(playerid);
        } else MostrarLogin(playerid);
        return 1;
    }
    return 0;
}
