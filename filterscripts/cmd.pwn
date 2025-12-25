#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <string>
#include <float>
#include <file>
#include <streamer>
#include "dini.inc"

// =====================
// CORES
// =====================
#define COR_BRANCO   0xFFFFFFFF
#define COR_VERMELHO 0xFF0000FF
#define COR_VERDE    0x00FF00FF
#define COR_AMARELO  0xFFFF00FF

// =====================
// DIALOGS
// =====================
#define DIALOG_LOGIN     1
#define DIALOG_REGISTRO  2

// =====================
// PATH
// =====================
#define USER_PATH "scriptfiles/contas/%s.ini"
#define HOUSE_PATH "scriptfiles/casas/%d.ini"

// =====================
// VARIÁVEIS
// =====================
new bool:Logado[MAX_PLAYERS];
new PlayerAdminLevel[MAX_PLAYERS];

new LastX[MAX_PLAYERS];
new LastY[MAX_PLAYERS];
new LastZ[MAX_PLAYERS];
new LastInterior[MAX_PLAYERS];
new LastVW[MAX_PLAYERS];

new PlayerHouse[MAX_PLAYERS]; // ID da casa que o player está
new HouseLocked[100];          // Trancada ou não
new HousePrice[100];           // Preço da casa
new HousePickup[100];          // Pickup da porta
new House3DLabel[100];         // 3DTextLabel da porta

// =====================
// AUXILIAR
// =====================
stock GetUserFile(playerid, dest[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(dest, size, USER_PATH, nome);
}

stock GetHouseFile(houseid, dest[], size)
{
    format(dest, size, HOUSE_PATH, houseid);
}

// =====================
// REGISTRO / LOGIN
// =====================
stock RegistrarConta(playerid, const senha[])
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    dini_Set(file, "Conta:Senha", senha);
    dini_IntSet(file, "Conta:Admin", 0);

    return 1;
}

stock bool:ChecarSenha(playerid, const senha[])
{
    new file[64], saved[64];
    GetUserFile(playerid, file, sizeof(file));
    strcpy(saved, dini_Get(file, "Conta:Senha"));
    return strcmp(saved, senha) == 0;
}

stock CarregarAdmin(playerid)
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));
    PlayerAdminLevel[playerid] = dini_Int(file, "Conta:Admin");
}

stock SalvarAdmin(playerid)
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));
    dini_IntSet(file, "Conta:Admin", PlayerAdminLevel[playerid]);
}

// =====================
// POSIÇÃO
// =====================
stock SalvarPosicao(playerid)
{
    if (!Logado[playerid]) return;

    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    new Float:x, y, z;
    GetPlayerPos(playerid, x, y, z);

    dini_FloatSet(file, "Posicao:X", x);
    dini_FloatSet(file, "Posicao:Y", y);
    dini_FloatSet(file, "Posicao:Z", z);
    dini_IntSet(file, "Posicao:Interior", GetPlayerInterior(playerid));
    dini_IntSet(file, "Posicao:VW", GetPlayerVirtualWorld(playerid));
}

stock CarregarPosicao(playerid)
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    LastX[playerid] = dini_Float(file, "Posicao:X");
    LastY[playerid] = dini_Float(file, "Posicao:Y");
    LastZ[playerid] = dini_Float(file, "Posicao:Z");
    LastInterior[playerid] = dini_Int(file, "Posicao:Interior");
    LastVW[playerid] = dini_Int(file, "Posicao:VW");
}

// =====================
// FILTERSCRIPT INIT
// =====================
public OnFilterScriptInit()
{
    print("[CMD] Sistema de Login/Admin e Casas carregado");
    return 1;
}

// =====================
// PLAYER CONNECT / DISCONNECT
// =====================
public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    PlayerAdminLevel[playerid] = 0;
    PlayerHouse[playerid] = 0;

    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    if (dini_Exists(file))
    {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
            "Login", "Digite sua senha:", "Entrar", "Sair");
    }
    else
    {
        ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD,
            "Registro", "Crie uma senha:", "Registrar", "Sair");
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    SalvarPosicao(playerid);
    return 1;
}

// =====================
// SPAWN
// =====================
public OnPlayerSpawn(playerid)
{
    if (LastX[playerid] != 0.0)
    {
        SetPlayerInterior(playerid, LastInterior[playerid]);
        SetPlayerVirtualWorld(playerid, LastVW[playerid]);
        SetPlayerPos(playerid, LastX[playerid], LastY[playerid], LastZ[playerid]);
    }
    else
    {
        SetPlayerPos(playerid, 1529.6, -1691.2, 13.3);
    }
}

// =====================
// DIALOG RESPONSE
// =====================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (!response) return Kick(playerid);

    if (dialogid == DIALOG_REGISTRO)
    {
        if (strlen(inputtext) < 3)
            return ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD,
                "Registro", "Senha muito curta!", "Registrar", "Sair");

        RegistrarConta(playerid, inputtext);
        Logado[playerid] = true;
        SpawnPlayer(playerid);
        SendClientMessage(playerid, COR_VERDE, "Conta criada com sucesso!");
        return 1;
    }

    if (dialogid == DIALOG_LOGIN)
    {
        if (!ChecarSenha(playerid, inputtext))
            return Kick(playerid);

        Logado[playerid] = true;
        CarregarAdmin(playerid);
        CarregarPosicao(playerid);
        SpawnPlayer(playerid);
        SendClientMessage(playerid, COR_VERDE, "Login efetuado!");
        return 1;
    }
    return 1;
}

// =====================
// CASA ADMIN / COMPRA / ENTRAR / VENDER
// =====================
CMD:sethouse(playerid, params[])
{
    if (PlayerAdminLevel[playerid] < 5)
        return SendClientMessage(playerid, COR_VERMELHO, "Sem permissão.");

    new id, price;
    if (sscanf(params, "ii", id, price))
        return SendClientMessage(playerid, COR_AMARELO, "/sethouse [id] [preço]");

    HousePrice[id] = price;
    HouseLocked[id] = true;

    new Float:x, y, z;
    GetPlayerPos(playerid, x, y, z);

    // Cria pickup e 3DTextLabel
    if (HousePickup[id] != 0) DestroyPickup(HousePickup[id]);
    if (House3DLabel[id] != 0) DestroyDynamic3DTextLabel(House3DLabel[id]);

    HousePickup[id] = CreatePickup(1272, x, y, z, 1, 0); // Tipo 1272 = chave
    House3DLabel[id] = CreateDynamic3DTextLabel("Casa trancada", 0xFF0000FF, x, y, z + 1.0, 10.0, 0);

    SendClientMessage(playerid, COR_VERDE, "Casa definida!");
}

// Comprar casa
CMD:buyhouse(playerid, params[])
{
    new id;
    if (sscanf(params, "i", id))
        return SendClientMessage(playerid, COR_AMARELO, "/buyhouse [id]");

    if (HouseLocked[id])
        return SendClientMessage(playerid, COR_VERMELHO, "Casa está trancada pelo admin.");

    new money = GetPlayerMoney(playerid);
    if (money < HousePrice[id])
        return SendClientMessage(playerid, COR_VERMELHO, "Dinheiro insuficiente.");

    TakePlayerMoney(playerid, HousePrice[id]);

    new file[64];
    GetHouseFile(id, file, sizeof(file));

    dini_Set(file, "Owner", GetPlayerName(playerid, file, sizeof(file)));
    HouseLocked[id] = true;
    PlayerHouse[playerid] = id;

    SendClientMessage(playerid, COR_VERDE, "Você comprou a casa!");
}

// Entrar na casa
CMD:enterhouse(playerid, params[])
{
    new id;
    if (sscanf(params, "i", id))
        return SendClientMessage(playerid, COR_AMARELO, "/enterhouse [id]");

    if (PlayerHouse[playerid] != id)
        return SendClientMessage(playerid, COR_VERMELHO, "Esta não é sua casa.");

    SetPlayerInterior(playerid, id + 100); // Interior diferente por casa
    SetPlayerVirtualWorld(playerid, id + 100);
    SetPlayerPos(playerid, 10.0, 10.0, 3.0);
}

// Vender casa
CMD:sellhouse(playerid, params[])
{
    new id;
    if (sscanf(params, "i", id))
        return SendClientMessage(playerid, COR_AMARELO, "/sellhouse [id]");

    if (PlayerHouse[playerid] != id)
        return SendClientMessage(playerid, COR_VERMELHO, "Você não possui esta casa.");

    PlayerHouse[playerid] = 0;
    HouseLocked[id] = false;

    new file[64];
    GetHouseFile(id, file, sizeof(file));
    dini_Unset(file, "Owner");

    GivePlayerMoney(playerid, HousePrice[id] / 2); // Recebe metade ao vender
    SendClientMessage(playerid, COR_VERDE, "Casa vendida com sucesso!");
}
