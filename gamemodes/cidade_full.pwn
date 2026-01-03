/* 
    CIDADE FULL 2026 - VERSÃO MYSQL MASTER FINAL
    Conexão LemeHost: Configurada
*/

#include <a_samp>
#include <zcmd>
#include <a_mysql> 

// --- CONFIGURAÇÕES DO BANCO DE DADOS (LemeHost) ---
#define MYSQL_HOST "51.38.205.167"
#define MYSQL_USER "u2201_cAUC56sxh3"
#define MYSQL_PASS "Qvuu1CvuEzdDMJRl5!1K2=R5"
#define MYSQL_DB   "s2201_Cidadefull"

// IDs de Dialog
#define DIALOG_LOGIN        2000
#define DIALOG_REGISTER     2001
#define DIALOG_LOJA         3000
#define SKIN_NOVATO         26

// COORDENADAS DE SPAWN
#define SPAWN_X 1642.8808
#define SPAWN_Y -2239.0747
#define SPAWN_Z 13.4961
#define SPAWN_A 177.5711

// Variáveis Globais
new MySQL:handle;
new bool:Logado[MAX_PLAYERS];
new BikeNovato[MAX_PLAYERS];
new PlayerCoins[MAX_PLAYERS];
new PickupBike;

main() 
{ 
    print("---------------------------------------");
    print("   CIDADE FULL 2026 - MYSQL LOADED     ");
    print("---------------------------------------");
}

public OnGameModeInit() {
    SetGameModeText("Cidade Full v4.5 MySQL");

    // Configurações de Conexão MySQL
    new MySQLOpt: options = mysql_init_options();
    mysql_set_option(options, MYSQL_OPT_RECONNECT, true);
    handle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DB, options);

    if(mysql_errno(handle) != 0) {
        print("[MYSQL]: ERRO - Falha ao conectar no banco da LemeHost!");
    } else {
        print("[MYSQL]: SUCESSO - Conectado ao banco de dados!");
    }

    PickupBike = CreatePickup(1239, 1, 1642.50, -2244.60, 13.50, -1);
    Create3DTextLabel("{00CCFF}ECO-BIKE\n{FFFFFF}Pise para pegar", 0xFFFFFFFF, 1642.50, -2244.60, 14.0, 10.0, 0, 0);
    AddPlayerClass(SKIN_NOVATO, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 0, 0, 0, 0, 0, 0);
    return 1;
}

public OnPlayerConnect(playerid) {
    Logado[playerid] = false;
    PlayerCoins[playerid] = 0;
    BikeNovato[playerid] = -1;

    new query[128], name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    mysql_format(handle, query, sizeof(query), "SELECT * FROM `contas` WHERE `nome` = '%e' LIMIT 1", name);
    mysql_tquery(handle, query, "VerificarConta", "i", playerid);
    return 1;
}

forward VerificarConta(playerid);
public VerificarConta(playerid) {
    if(cache_num_rows() > 0) {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{00CCFF}Login MySQL", "Digite sua senha para entrar:", "Entrar", "Sair");
    } else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{00CCFF}Registro MySQL", "Crie uma senha para se registrar:", "Registrar", "Sair");
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    if(Logado[playerid]) {
        new query[150], name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, name, sizeof(name));
        mysql_format(handle, query, sizeof(query), "UPDATE `contas` SET `grana` = %d, `coins` = %d WHERE `nome` = '%e'", 
            GetPlayerMoney(playerid), PlayerCoins[playerid], name);
        mysql_tquery(handle, query);
    }
    if(BikeNovato[playerid] != -1) DestroyVehicle(BikeNovato[playerid]);
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    new query[256], name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));

    if(dialogid == DIALOG_REGISTER) {
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 4) return VerificarConta(playerid);

        mysql_format(handle, query, sizeof(query), "INSERT INTO `contas` (`nome`, `senha`, `grana`, `coins`) VALUES ('%e', '%e', 5000, 0)", name, inputtext);
        mysql_tquery(handle, query, "AposRegistro", "i", playerid);
        return 1;
    }

    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        mysql_format(handle, query, sizeof(query), "SELECT * FROM `contas` WHERE `nome` = '%e' AND `senha` = '%e' LIMIT 1", name, inputtext);
        mysql_tquery(handle, query, "AposLogin", "i", playerid);
        return 1;
    }

    if(dialogid == DIALOG_LOJA) {
        if(!response) return 1;
        new preco, veh;
        switch(listitem) {
            case 0: { preco = 500; veh = 411; }
            case 1: { preco = 400; veh = 522; }
            case 2: {
                if(PlayerCoins[playerid] < 100) return SendClientMessage(playerid, -1, "{FF0000}Coins insuficientes!");
                PlayerCoins[playerid] -= 100;
                SetPlayerSkin(playerid, 294);
                return SendClientMessage(playerid, -1, "{00FF00}Skin comprada!");
            }
        }
        if(PlayerCoins[playerid] < preco) return SendClientMessage(playerid, -1, "{FF0000}Coins insuficientes!");
        PlayerCoins[playerid] -= preco;
        CreateVehicle(veh, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 1, 1, -1);
        SendClientMessage(playerid, -1, "{00FF00}Veículo Premium adquirido!");
        return 1;
    }
    return 0;
}

forward AposRegistro(playerid);
public AposRegistro(playerid) {
    Logado[playerid] = true;
    PlayerCoins[playerid] = 0;
    GivePlayerMoney(playerid, 5000);
    SetSpawnInfo(playerid, 0, SKIN_NOVATO, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);
    return 1;
}

forward AposLogin(playerid);
public AposLogin(playerid) {
    if(cache_num_rows() > 0) {
        Logado[playerid] = true;
        new grana_temp, coins_temp;
        cache_get_value_name_int(0, "grana", grana_temp);
        cache_get_value_name_int(0, "coins", coins_temp);
        
        GivePlayerMoney(playerid, grana_temp);
        PlayerCoins[playerid] = coins_temp;
        
        SetSpawnInfo(playerid, 0, SKIN_NOVATO, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_A, 0, 0, 0, 0, 0, 0);
        SpawnPlayer(playerid);
    } else {
        SendClientMessage(playerid, -1, "{FF0000}Senha incorreta!");
        VerificarConta(playerid);
    }
    return 1;
}

CMD:loja(playerid, params[]) {
    if(!Logado[playerid]) return 0;
    new str[256];
    format(str, sizeof(str), "{FFFFFF}Coins: {00FF00}%d\n\n{FFFFFF}Infernus - 500 Coins\nNRG-500 - 400 Coins\nSkin Wu Zi Mu - 100 Coins", PlayerCoins[playerid]);
    ShowPlayerDialog(playerid, DIALOG_LOJA, DIALOG_STYLE_LIST, "{FFFF00}Loja Premium", str, "Comprar", "Sair");
    return 1;
}

CMD:meussaldos(playerid, params[]) {
    new str[128];
    format(str, sizeof(str), "{FFFF00}Grana: {00FF00}$%d {FFFF00}| Coins: {00FF00}%d", GetPlayerMoney(playerid), PlayerCoins[playerid]);
    SendClientMessage(playerid, -1, str);
    return 1;
}

// --- ECO-BIKE ---
public OnPlayerSpawn(playerid) {
    SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid) {
    if(pickupid == PickupBike) {
        if(IsPlayerInAnyVehicle(playerid)) return 1;
        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
        if(BikeNovato[playerid] != -1) DestroyVehicle(BikeNovato[playerid]);
        BikeNovato[playerid] = CreateVehicle(510, x, y, z + 0.8, a, 1, 1, -1);
        PutPlayerInVehicle(playerid, BikeNovato[playerid], 0);
    }
    return 1;
}
