#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <simple_ini>

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
// FUNÇÕES AUX
// =====================
stock GetUserFile(playerid, dest[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(dest, size, USER_PATH, nome);
}

// =====================
// REGISTRO
// =====================
stock RegistrarConta(playerid, const senha[])
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    WriteINIString(file, "Conta", "Senha", senha);
    WriteINIInt(file, "Conta", "Admin", 0);

    return 1;
}

// =====================
// CHECAR SENHA
// =====================
stock bool:ChecarSenha(playerid, const senha[])
{
    new file[64], saved[64];
    GetUserFile(playerid, file, sizeof(file));

    ReadINIString(file, "Conta", "Senha", "", saved, sizeof(saved));
    return strcmp(saved, senha) == 0;
}

// =====================
// ADMIN
// =====================
stock CarregarAdmin(playerid)
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    PlayerAdminLevel[playerid] = ReadINIInt(file, "Conta", "Admin", 0);
}

stock SalvarAdmin(playerid)
{
    new file[64], senha[64];
    GetUserFile(playerid, file, sizeof(file));

    ReadINIString(file, "Conta", "Senha", "", senha, sizeof(senha));
    WriteINIString(file, "Conta", "Senha", senha);
    WriteINIInt(file, "Conta", "Admin", PlayerAdminLevel[playerid]);
}

// =====================
// POSIÇÃO
// =====================
stock SalvarPosicao(playerid)
{
    if (!Logado[playerid]) return;

    new file[64], senha[64];
    GetUserFile(playerid, file, sizeof(file));

    ReadINIString(file, "Conta", "Senha", "", senha, sizeof(senha));

    new Float:x, y, z;
    GetPlayerPos(playerid, x, y, z);

    WriteINIString(file, "Conta", "Senha", senha);
    WriteINIInt(file, "Conta", "Admin", PlayerAdminLevel[playerid]);
    WriteINIFloat(file, "Posicao", "X", x);
    WriteINIFloat(file, "Posicao", "Y", y);
    WriteINIFloat(file, "Posicao", "Z", z);
    WriteINIInt(file, "Posicao", "Interior", GetPlayerInterior(playerid));
    WriteINIInt(file, "Posicao", "VW", GetPlayerVirtualWorld(playerid));
}

stock CarregarPosicao(playerid)
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    LastX[playerid] = ReadINIFloat(file, "Posicao", "X", 0.0);
    LastY[playerid] = ReadINIFloat(file, "Posicao", "Y", 0.0);
    LastZ[playerid] = ReadINIFloat(file, "Posicao", "Z", 0.0);
    LastInterior[playerid] = ReadINIInt(file, "Posicao", "Interior", 0);
    LastVW[playerid] = ReadINIInt(file, "Posicao", "VW", 0);
}

// =====================
// FILTERSCRIPT
// =====================
public OnFilterScriptInit()
{
    print("[CMD] Sistema de Login/Admin carregado");
    return 1;
}

// =====================
// CONNECT
// =====================
public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    PlayerAdminLevel[playerid] = 0;

    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    if (fexist(file))
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

// =====================
// DISCONNECT
// =====================
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
// COMANDO ADMIN
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
