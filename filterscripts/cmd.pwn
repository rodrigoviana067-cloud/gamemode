#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <dini>

// =======================
// CORES
// =======================
#define COR_BRANCO    0xFFFFFFFF
#define COR_VERMELHO  0xFF0000FF
#define COR_VERDE     0x00FF00FF
#define COR_AMARELO   0xFFFF00FF

// =======================
// DIALOGS
// =======================
#define DIALOG_LOGIN     1
#define DIALOG_REGISTRO  2

// =======================
// PATH
// =======================
#define USER_PATH   "scriptfiles/contas/%s.ini"
#define CASA_PATH   "scriptfiles/casas/%d.ini"
#define PLAYER_PATH "scriptfiles/players/%s.ini"

// =======================
// VARIÁVEIS
// =======================
new bool:Logado[MAX_PLAYERS];
new PlayerAdminLevel[MAX_PLAYERS];

new Float:LastX[MAX_PLAYERS];
new Float:LastY[MAX_PLAYERS];
new Float:LastZ[MAX_PLAYERS];
new LastInterior[MAX_PLAYERS];
new LastVW[MAX_PLAYERS];

new PlayerCasa[MAX_PLAYERS];
new CasaPickup[1000];
new Text3D:CasaLabel[1000];

// =======================
// FUNÇÕES AUXILIARES
// =======================
stock GetUserFile(playerid, dest[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(dest, size, USER_PATH, nome);
}

stock RegistrarConta(playerid, const senha[])
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    dini_Create(file);
    dini_Set(file, "Senha", senha);
    dini_IntSet(file, "Admin", 0);

    return 1;
}

stock bool:ChecarSenha(playerid, const senha[])
{
    new file[64], saved[64];
    GetUserFile(playerid, file, sizeof(file));

    dini_Get(file, "Senha", saved);
    return strcmp(saved, senha) == 0;
}

stock CarregarAdmin(playerid)
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    PlayerAdminLevel[playerid] = dini_Int(file, "Admin");
}

stock SalvarAdmin(playerid)
{
    new file[64], senha[64];
    GetUserFile(playerid, file, sizeof(file));

    dini_Get(file, "Senha", senha);
    dini_Set(file, "Senha", senha);
    dini_IntSet(file, "Admin", PlayerAdminLevel[playerid]);
}

// =======================
// POSIÇÃO
// =======================
stock SalvarPosicao(playerid)
{
    if (!Logado[playerid]) return;

    new file[64], senha[64];
    GetUserFile(playerid, file, sizeof(file));

    dini_Get(file, "Senha", senha);

    new Float:x, y, z;
    GetPlayerPos(playerid, x, y, z);

    dini_Set(file, "Senha", senha);
    dini_IntSet(file, "Admin", PlayerAdminLevel[playerid]);
    dini_FloatSet(file, "X", x);
    dini_FloatSet(file, "Y", y);
    dini_FloatSet(file, "Z", z);
    dini_IntSet(file, "Interior", GetPlayerInterior(playerid));
    dini_IntSet(file, "VW", GetPlayerVirtualWorld(playerid));
}

stock CarregarPosicao(playerid)
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    LastX[playerid] = dini_Float(file, "X");
    LastY[playerid] = dini_Float(file, "Y");
    LastZ[playerid] = dini_Float(file, "Z");
    LastInterior[playerid] = dini_Int(file, "Interior");
    LastVW[playerid] = dini_Int(file, "VW");
}

// =======================
// SISTEMA DE CASAS
// =======================
stock CriarLabelCasa(id)
{
    new file[64], texto[128];
    format(file, sizeof(file), CASA_PATH, id);

    if (!dini_Exists(file)) return 0;

    format(texto, sizeof(texto),
        "{FFFFFF}Casa ID: {00FF00}%d\n{FFFFFF}Preco: {00FF00}$%d\n{FFFFFF}/entrarcasa %d",
        id,
        dini_Int(file, "Preco"),
        id
    );

    CasaLabel[id] = Create3DTextLabel(
        texto, COR_VERDE,
        dini_Float(file, "X"),
        dini_Float(file, "Y"),
        dini_Float(file, "Z"),
        15.0, 0, 1
    );

    CasaPickup[id] = CreatePickup(
        1273, 1,
        dini_Float(file, "X"),
        dini_Float(file, "Y"),
        dini_Float(file, "Z"),
        -1
    );
    return 1;
}

stock SalvarPlayer(playerid)
{
    new nome[MAX_PLAYER_NAME], file[64];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(file, sizeof(file), PLAYER_PATH, nome);

    dini_IntSet(file, "Casa", PlayerCasa[playerid]);
    return 1;
}

stock CarregarPlayer(playerid)
{
    new nome[MAX_PLAYER_NAME], file[64];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(file, sizeof(file), PLAYER_PATH, nome);

    if (!dini_Exists(file))
    {
        dini_Create(file);
        dini_IntSet(file, "Casa", -1);
    }

    PlayerCasa[playerid] = dini_Int(file, "Casa");
    return 1;
}

// =======================
// FILTERSCRIPT INIT
// =======================
public OnFilterScriptInit()
{
    print("[SYSTEM] Login/Admin e Casas carregados");
    for (new i = 1; i < 1000; i++)
        CriarLabelCasa(i);
    return 1;
}

// =======================
// CONNECT/DISCONNECT
// =======================
public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    PlayerAdminLevel[playerid] = 0;
    PlayerCasa[playerid] = -1;

    CarregarPlayer(playerid);

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
    SalvarPlayer(playerid);
    return 1;
}

// =======================
// SPAWN
// =======================
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
    return 1;
}

// =======================
// DIALOG
// =======================
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

// =======================
// COMANDOS ADMIN
// =======================
CMD:setadmin(playerid, params[])
{
    if (PlayerAdminLevel[playerid] < 5)
        return SendClientMessage(playerid, COR_VERMELHO, "Sem permissão.");

    new id, nivel;
    if (sscanf(params, "ii", id, nivel))
        return SendClientMessage(playerid, COR_AMARELO, "/setadmin [id] [nivel]");

    PlayerAdminLevel[id] = nivel;
    SalvarAdmin(id);

    SendClientMessage(id, COR_VERDE, "Você recebeu admin!");
    SendClientMessage(playerid, COR_VERDE, "Admin definido.");
    return 1;
}

// =======================
// COMANDOS CASAS
// =======================
CMD:criarcasa(playerid, params[])
{
    if (PlayerAdminLevel[playerid] < 5)
        return SendClientMessage(playerid, COR_VERMELHO, "Sem permissão.");

    new preco, interior;
    if (sscanf(params, "ii", preco, interior))
        return SendClientMessage(playerid, COR_AMARELO, "/criarcasa [preco] [interior]");

    new id = 1, file[64];
    while (true)
    {
        format(file, sizeof(file), CASA_PATH, id);
        if (!dini_Exists(file)) break;
        id++;
    }

    new Float:x, y, z;
    GetPlayerPos(playerid, x, y, z);

    dini_Create(file);
    dini_IntSet(file, "Dono", -1);
    dini_IntSet(file, "Preco", preco);
    dini_IntSet(file, "Interior", interior);
    dini_IntSet(file, "Trancada", 0);
    dini_IntSet(file, "VW", id);

    dini_FloatSet(file, "X", x);
    dini_FloatSet(file, "Y", y);
    dini_FloatSet(file, "Z", z);

    CriarLabelCasa(id);
    SendClientMessage(playerid, COR_VERDE, "Casa criada.");
    return 1;
}

CMD:comprarcasa(playerid, params[])
{
    new id, file[64];
    if (sscanf(params, "i", id)) return 0;

    format(file, sizeof(file), CASA_PATH, id);

    if (dini_Int(file, "Dono") != -1)
        return SendClientMessage(playerid, COR_VERMELHO, "Casa ja tem dono.");

    new preco = dini_Int(file, "Preco");
    if (GetPlayerMoney(playerid) < preco)
        return SendClientMessage(playerid, COR_VERMELHO, "Dinheiro insuficiente.");

    TakePlayerMoney(playerid, preco);
    dini_IntSet(file, "Dono", playerid);
    PlayerCasa[playerid] = id;

    SendClientMessage(playerid, COR_VERDE, "Casa comprada.");
    return 1;
}

CMD:entrarcasa(playerid, params[])
{
    new id, file[64];
    if (sscanf(params, "i", id)) return 0;

    format(file, sizeof(file), CASA_PATH, id);

    if (dini_Int(file, "Trancada") == 1 && dini_Int(file, "Dono") != playerid)
        return SendClientMessage(playerid, COR_VERMELHO, "Casa trancada.");

    SetPlayerInterior(playerid, dini_Int(file, "Interior"));
    SetPlayerVirtualWorld(playerid, dini_Int(file, "VW"));
    SetPlayerPos(playerid, 223.0, 1287.0, 1082.1);

    return 1;
}

CMD:saircasa(playerid, params[])
{
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, 1529.6, -1691.2, 13.3);
    return 1;
}

CMD:trancar(playerid, params[])
{
    new id = PlayerCasa[playerid], file[64];
    if (id == -1) return 0;

    format(file, sizeof(file), CASA_PATH, id);

    new estado = dini_Int(file, "Trancada");
    dini_IntSet(file, "Trancada", !estado);

    SendClientMessage(playerid, COR_VERDE, estado ? "Casa destrancada." : "Casa trancada.");
    return 1;
}

CMD:vendercasa(playerid, params[])
{
    new id = PlayerCasa[playerid], file[64];
    if (id == -1) return 0;

    format(file, sizeof(file), CASA_PATH, id);

    GivePlayerMoney(playerid, dini_Int(file, "Preco") / 2);
    dini_IntSet(file, "Dono", -1);
    PlayerCasa[playerid] = -1;

    SendClientMessage(playerid, COR_VERDE, "Casa vendida.");
    return 1;
}
