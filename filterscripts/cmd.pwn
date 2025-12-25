#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <dini>

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
// PATHS
// =====================
#define USER_PATH "scriptfiles/contas/%s.ini"
#define HOUSE_PATH "scriptfiles/casas/%d.ini"

// =====================
// VARIÁVEIS
// =====================
new bool:Logado[MAX_PLAYERS];
new PlayerAdminLevel[MAX_PLAYERS];

new Float:LastX[MAX_PLAYERS];
new Float:LastY[MAX_PLAYERS];
new Float:LastZ[MAX_PLAYERS];
new LastInterior[MAX_PLAYERS];
new LastVW[MAX_PLAYERS];

// =====================
// AUXILIARES
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
// CONTA
// =====================
stock RegistrarConta(playerid, const senha[])
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    dini_Create(file);
    dini_Set(file, "Conta", "Senha", senha);
    dini_IntSet(file, "Conta", "Admin", 0);

    return 1;
}

stock bool:ChecarSenha(playerid, const senha[])
{
    new file[64], saved[64];
    GetUserFile(playerid, file, sizeof(file));

    dini_Get(file, "Conta", "Senha", saved, sizeof(saved));
    return strcmp(saved, senha) == 0;
}

stock CarregarAdmin(playerid)
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    PlayerAdminLevel[playerid] = dini_Int(file, "Conta", "Admin");
}

stock SalvarAdmin(playerid)
{
    new file[64], senha[64];
    GetUserFile(playerid, file, sizeof(file));

    dini_Get(file, "Conta", "Senha", senha, sizeof(senha));
    dini_Set(file, "Conta", "Senha", senha);
    dini_IntSet(file, "Conta", "Admin", PlayerAdminLevel[playerid]);
}

// =====================
// POSIÇÃO
// =====================
stock SalvarPosicao(playerid)
{
    if (!Logado[playerid]) return;

    new file[64], senha[64];
    GetUserFile(playerid, file, sizeof(file));

    dini_Get(file, "Conta", "Senha", senha, sizeof(senha));

    new Float:x, y, z;
    GetPlayerPos(playerid, x, y, z);

    dini_Set(file, "Conta", "Senha", senha);
    dini_IntSet(file, "Conta", "Admin", PlayerAdminLevel[playerid]);
    dini_FloatSet(file, "Posicao_X", "X", x);
    dini_FloatSet(file, "Posicao_Y", "Y", y);
    dini_FloatSet(file, "Posicao_Z", "Z", z);
    dini_IntSet(file, "Posicao", "Interior", GetPlayerInterior(playerid));
    dini_IntSet(file, "Posicao", "VW", GetPlayerVirtualWorld(playerid));
}

stock CarregarPosicao(playerid)
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    LastX[playerid] = dini_Float(file, "Posicao_X");
    LastY[playerid] = dini_Float(file, "Posicao_Y");
    LastZ[playerid] = dini_Float(file, "Posicao_Z");
    LastInterior[playerid] = dini_Int(file, "Posicao", "Interior");
    LastVW[playerid] = dini_Int(file, "Posicao", "VW");
}

// =====================
// FILTERSCRIPT
// =====================
public OnFilterScriptInit()
{
    print("[CMD] Sistema de Login/Admin e Casas carregado");
    return 1;
}

// =====================
// CONNECT / SPAWN / DISCONNECT
// =====================
public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    PlayerAdminLevel[playerid] = 0;

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

public OnPlayerDisconnect(playerid, reason)
{
    SalvarPosicao(playerid);
    return 1;
}

// =====================
// DIALOG
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
// ADMIN
// =====================
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

// =====================
// CASAS
// =====================
CMD:comprarhouse(playerid, params[])
{
    if (!Logado[playerid]) return 0;

    new houseid;
    if (sscanf(params, "i", houseid))
        return SendClientMessage(playerid, COR_AMARELO, "/comprarhouse [id]");

    new file[64];
    GetHouseFile(houseid, file, sizeof(file));

    if (!dini_Exists(file))
    {
        dini_Create(file);
        dini_IntSet(file, "Casa", "DonoID", playerid);
        SendClientMessage(playerid, COR_VERDE, "Casa comprada com sucesso!");
    }
    else
    {
        SendClientMessage(playerid, COR_VERMELHO, "Esta casa já está ocupada!");
    }
    return 1;
}

CMD:entrarhouse(playerid, params[])
{
    if (!Logado[playerid]) return 0;

    new houseid;
    if (sscanf(params, "i", houseid))
        return SendClientMessage(playerid, COR_AMARELO, "/entrarhouse [id]");

    new file[64];
    GetHouseFile(houseid, file, sizeof(file));

    if (!dini_Exists(file))
    {
        SendClientMessage(playerid, COR_VERMELHO, "Esta casa não existe!");
        return 1;
    }

    new donoID = dini_Int(file, "Casa", "DonoID");
    if (donoID != playerid && PlayerAdminLevel[playerid] < 5)
    {
        SendClientMessage(playerid, COR_VERMELHO, "Você não é o dono desta casa!");
        return 1;
    }

    // Teleport dentro da casa
    SetPlayerPos(playerid, 2000.0, 2000.0, 10.0); // Exemplo, mude as coordenadas
    SendClientMessage(playerid, COR_VERDE, "Bem-vindo à sua casa!");
    return 1;
}
