/* 
    CIDADE FULL 2026 - VERSÃO MASTER FINAL (LOJA PREMIUM ATIVADA)
*/

#include <a_samp>
#include <zcmd>
#include <dini>

// IDs de Dialog
#define DIALOG_LOGIN        2000
#define DIALOG_REGISTER     2001
#define DIALOG_LOJA         3000 // Novo ID para a loja
#define SKIN_NOVATO         26

// NOVAS COORDENADAS DE SPAWN (LS)
#define SPAWN_X 1642.8808
#define SPAWN_Y -2239.0747
#define SPAWN_Z 13.4961
#define SPAWN_A 177.5711

new bool:Logado[MAX_PLAYERS];
new BikeNovato[MAX_PLAYERS];
new PlayerCoins[MAX_PLAYERS]; // Variável que armazena os Coins
new PickupBike;

main() 
{ 
    print("---------------------------------------");
    print("   CIDADE FULL 2026 - LOJA PREMIUM     ");
    print("---------------------------------------");
}

// --- Funções de Conta ---
stock GetConta(playerid) {
    new str[64], name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), "contas/%s.ini", name);
    return str;
}

forward MostrarLogin(playerid);
public MostrarLogin(playerid) {
    if (dini_Exists(GetConta(playerid))) {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{00CCFF}Login 2026", "Digite sua senha para entrar:", "Entrar", "Sair");
    } else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{00CCFF}Registro 2026", "Crie uma senha para sua conta:", "Registrar", "Sair");
    }
}

// --- COMANDOS ZCMD ---

CMD:meuscoins(playerid, params[]) {
    new str[128];
    format(str, sizeof(str), "{FFFF00}[BANCO] {FFFFFF}Saldo atual: {00FF00}%d Coins.", PlayerCoins[playerid]);
    SendClientMessage(playerid, -1, str);
    return 1;
}

CMD:darcoins(playerid, params[]) { // Comando para você testar (Dá 1000 coins)
    PlayerCoins[playerid] += 1000;
    SendClientMessage(playerid, 0x00FF00FF, "[ADM] Você recebeu 1000 Coins de teste!");
    return 1;
}

CMD:loja(playerid, params[]) {
    if(!Logado[playerid]) return 0;
    ShowPlayerDialog(playerid, DIALOG_LOJA, DIALOG_STYLE_LIST, "{FFFF00}Loja Premium 2026", 
    "1. Veículo Infernus (Premium) - 500 Coins\n2. Veículo NRG-500 (Premium) - 400 Coins\n3. Skin Especial (Rara) - 100 Coins", "Comprar", "Sair");
    return 1;
}

// --- CALLBACKS ---

public OnGameModeInit() {
    SetGameModeText("Cidade Full v4.5");
    PickupBike = CreatePickup(1239, 1, 1642.50, -2244.60, 13.50, -1);
    Create3DTextLabel("{00CCFF}ECO-BIKE\n{FFFFFF}Pise para pegar", 0xFFFFFFFF, 1642.50, -2244.60, 14.0, 10.0, 0, 0);
    AddPlayerClass(SKIN_NOVATO, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 0, 0, 0, 0, 0, 0);
    return 1;
}

public OnPlayerConnect(playerid) {
    Logado[playerid] = false;
    BikeNovato[playerid] = -1;
    PlayerCoins[playerid] = 0; // Reset ao conectar
    SetTimerEx("MostrarLogin", 1500, false, "i", playerid); 
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    if(Logado[playerid]) {
        new path[64]; 
        format(path, sizeof(path), GetConta(playerid));
        dini_IntSet(path, "Grana", GetPlayerMoney(playerid)); 
        dini_IntSet(path, "Coins", PlayerCoins[playerid]); // SALVA OS COINS AO SAIR
    }
    if(BikeNovato[playerid] != -1) DestroyVehicle(BikeNovato[playerid]);
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    new path[64];
    format(path, sizeof(path), GetConta(playerid));

    if(dialogid == DIALOG_REGISTER) {
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 4) return MostrarLogin(playerid);
        dini_Create(path);
        dini_Set(path, "Senha", inputtext);
        dini_IntSet(path, "Grana", 5000);
        dini_IntSet(path, "Coins", 0); // REGISTRA COM 0 COINS
        Logado[playerid] = true;
        SetSpawnInfo(playerid, 0, SKIN_NOVATO, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 0, 0, 0, 0, 0, 0);
        SpawnPlayer(playerid);
        return 1;
    }

    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        if(!strcmp(inputtext, dini_Get(path, "Senha"))) {
            Logado[playerid] = true;
            GivePlayerMoney(playerid, dini_Int(path, "Grana"));
            PlayerCoins[playerid] = dini_Int(path, "Coins"); // CARREGA OS COINS DO ARQUIVO
            SetSpawnInfo(playerid, 0, SKIN_NOVATO, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 0, 0, 0, 0, 0, 0);
            SpawnPlayer(playerid);
        } else MostrarLogin(playerid);
        return 1;
    }

    if(dialogid == DIALOG_LOJA) {
        if(!response) return 1;
        
        switch(listitem) {
            case 0: { // Infernus
                if(PlayerCoins[playerid] < 500) return SendClientMessage(playerid, 0xFF0000FF, "Você não tem Coins suficientes!");
                PlayerCoins[playerid] -= 500;
                CreateVehicle(411, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 1, 1, -1);
                SendClientMessage(playerid, 0x00FF00FF, "Você comprou um Infernus Premium!");
            }
            case 1: { // NRG-500
                if(PlayerCoins[playerid] < 400) return SendClientMessage(playerid, 0xFF0000FF, "Você não tem Coins suficientes!");
                PlayerCoins[playerid] -= 400;
                CreateVehicle(522, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 1, 1, -1);
                SendClientMessage(playerid, 0x00FF00FF, "Você comprou uma NRG-500 Premium!");
            }
            case 2: { // Skin
                if(PlayerCoins[playerid] < 100) return SendClientMessage(playerid, 0xFF0000FF, "Você não tem Coins suficientes!");
                PlayerCoins[playerid] -= 100;
                SetPlayerSkin(playerid, 294); // Skin do Wu Zi Mu
                SendClientMessage(playerid, 0x00FF00FF, "Você comprou uma Skin Premium!");
            }
        }
        return 1;
    }
    return 0; 
}

// --- Resto dos seus Callbacks Originais ---
public OnPlayerSpawn(playerid) {
    if(!Logado[playerid]) return Kick(playerid);
    SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
    SetPlayerFacingAngle(playerid, SPAWN_A);
    SetCameraBehindPlayer(playerid);
    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid) {
    if(pickupid == PickupBike) {
        if(IsPlayerInAnyVehicle(playerid)) return 1;
        if(BikeNovato[playerid] != -1) DestroyVehicle(BikeNovato[playerid]);
        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
        BikeNovato[playerid] = CreateVehicle(510, x, y, z + 0.8, a, 1, 1, -1);
        SetTimerEx("MontarNaBike", 250, false, "ii", playerid, BikeNovato[playerid]);
    }
    return 1;
}

forward MontarNaBike(playerid, vehicleid);
public MontarNaBike(playerid, vehicleid) { PutPlayerInVehicle(playerid, vehicleid, 0); }
