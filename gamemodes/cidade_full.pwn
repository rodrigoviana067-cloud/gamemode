/* 
    GAMEMODE: CIDADE FULL 2026 
    Sistemas: Login/Registro, Banco, Spawn Aeroporto, Pickup de Bikes.
*/

#include <a_samp>
#include <zcmd>
#include <dini>

// Configurações e IDs
#define DIALOG_LOGIN        1
#define DIALOG_REGISTER     2
#define DIALOG_GUIA         3

new bool:Logado[MAX_PLAYERS];
new BikeNovato[MAX_PLAYERS];
new PickupBike;

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
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{00CCFF}Login", "Bem-vindo de volta!\nDigite sua senha abaixo para entrar:", "Entrar", "Sair");
    } else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{00CCFF}Registro", "Você é novo por aqui!\nCrie uma senha para sua conta:", "Registrar", "Sair");
    }
}

// --- Início do GameMode ---

main() { print(">> Cidade Full 2026 Carregada."); }

public OnGameModeInit() {
    SetGameModeText("Cidade Full v2.0 - 2026");
    
    // Pickup de Bike no Aeroporto (ID 1239 - Informação)
    // Local: Saída do desembarque do aeroporto de LS
    PickupBike = CreatePickup(1239, 1, 1642.47, -2239.31, 13.49, -1);
    Create3DTextLabel("{FFFF00}SISTEMA DE BIKE GRATUITA\n{FFFFFF}Pise aqui para pegar uma bike!", 0xFFFFFFFF, 1642.47, -2239.31, 13.80, 15.0, 0, 0);
    
    // Banco LS Pickup
    CreatePickup(1274, 1, 1467.0, -1010.0, 26.0, -1); 
    return 1;
}

public OnPlayerConnect(playerid) {
    Logado[playerid] = false;
    BikeNovato[playerid] = -1;
    SetTimerEx("MostrarLogin", 1000, false, "i", playerid);
    return 1;
}

public OnPlayerSpawn(playerid) {
    if(!Logado[playerid]) return Kick(playerid);
    
    // Spawn dentro do Aeroporto (Terminal de Desembarque)
    SetPlayerPos(playerid, 1642.17, -2256.39, 13.49); 
    SetPlayerFacingAngle(playerid, 178.0);
    SetCameraBehindPlayer(playerid);
    
    SendClientMessage(playerid, 0x00FF00FF, "[CIDADE FULL] Você desembarcou no Aeroporto de Los Santos!");
    SendClientMessage(playerid, -1, "DICA: Use /guia para entender o servidor.");
    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid) {
    if(pickupid == PickupBike) {
        if(IsPlayerInAnyVehicle(playerid)) return 1;
        
        if(BikeNovato[playerid] != -1) DestroyVehicle(BikeNovato[playerid]);
        
        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
        
        // Cria a bike e coloca o player dentro (ID 510 = Mountain Bike)
        BikeNovato[playerid] = CreateVehicle(510, x, y, z + 0.5, a, 1, 1, -1);
        PutPlayerInVehicle(playerid, BikeNovato[playerid], 0);
        
        SendClientMessage(playerid, 0xFFFF00FF, "Bike entregue! Pedale (W) para andar. Ela sumirá se você descer.");
    }
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate) {
    // Sistema Anti-Poluição: Se descer da bike, ela some.
    if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT) {
        if(BikeNovato[playerid] != -1) {
            DestroyVehicle(BikeNovato[playerid]);
            BikeNovato[playerid] = -1;
            SendClientMessage(playerid, 0xFF0000FF, "Sua bike temporária foi removida.");
        }
    }
    return 1;
}

// --- Comandos ---

CMD:guia(playerid, params[]) {
    new string[500];
    strcat(string, "{FFFF00}--- GUIA DO NOVATO 2026 ---\n\n");
    strcat(string, "{FFFFFF}1. Você começa no Aeroporto de Los Santos.\n");
    strcat(string, "2. Vá até o {00FF00}Ícone 'i' {FFFFFF}na saída para pegar sua Bike.\n");
    strcat(string, "3. As bikes são gratuitas, mas desaparecem se você abandoná-las.\n");
    strcat(string, "4. Use o GPS (em breve) para encontrar o Banco e a Prefeitura.\n");
    strcat(string, "5. Evite poluir a cidade, use transportes sustentáveis!");
    ShowPlayerDialog(playerid, DIALOG_GUIA, DIALOG_STYLE_MSGBOX, "Guia do Servidor", string, "Entendido", "");
    return 1;
}

// --- Respostas de Diálogos ---

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == DIALOG_REGISTER) {
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 4) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{00CCFF}Erro", "A senha deve ter no mínimo 4 caracteres!", "Registrar", "Sair");
        
        dini_Create(GetConta(playerid));
        dini_Set(GetConta(playerid), "Senha", inputtext);
        dini_IntSet(GetConta(playerid), "Grana", 5000);
        Logado[playerid] = true;
        SpawnPlayer(playerid);
        return 1;
    }
    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        if(!strcmp(inputtext, dini_Get(GetConta(playerid), "Senha"))) {
            GivePlayerMoney(playerid, dini_Int(GetConta(playerid), "Grana"));
            Logado[playerid] = true;
            SpawnPlayer(playerid);
        } else {
            SendClientMessage(playerid, 0xFF0000FF, "Senha incorreta!");
            MostrarLogin(playerid);
        }
        return 1;
    }
    return 1;
}
