#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <simple_ini> // <<< aqui usamos o ini.inc

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
// FUNÇÃO AUXILIAR STRNCMP
// =====================
stock bool:strn_cmp(const s1[], const s2[], n)
{
    new temp1[128], temp2[128];
    strmid(temp1, s1, 0, n);
    strmid(temp2, s2, 0, n);
    return strcmp(temp1, temp2) == 0;
}

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

    ini_Open(file);
    ini_WriteString("Conta", "Senha", senha);
    ini_WriteInt("Conta", "Admin", 0);
    ini_Close();

    return 1;
}

// =====================
// CHECAR SENHA
// =====================
stock bool:ChecarSenha(playerid, const senha[])
{
    new file[64], saved[64];
    GetUserFile(playerid, file, sizeof(file));

    ini_Open(file);
    ini_ReadString("Conta", "Senha", "", saved, sizeof(saved));
    ini_Close();

    return !strcmp(saved, senha);
}

// =====================
// ADMIN
// =====================
stock CarregarAdmin(playerid)
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    ini_Open(file);
    PlayerAdminLevel[playerid] = ini_ReadInt("Conta", "Admin", 0);
    ini_Close();
}

stock SalvarAdmin(playerid)
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    new senha[64];
    if (!GetSenhaSalva(playerid, senha, sizeof(senha))) return;

    ini_Open(file);
    ini_WriteString("Conta", "Senha", senha);
    ini_WriteInt("Conta", "Admin", PlayerAdminLevel[playerid]);
    ini_Close();
}

// =====================
// SENHA
// =====================
stock GetSenhaSalva(playerid, senha[], size)
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    ini_Open(file);
    ini_ReadString("Conta", "Senha", "", senha, size);
    ini_Close();

    return strlen(senha) > 0;
}

// =====================
// POSIÇÃO
// =====================
stock SalvarPosicao(playerid)
{
    if (!Logado[playerid]) return;

    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    new senha[64];
    if (!GetSenhaSalva(playerid, senha, sizeof(senha))) return;

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    ini_Open(file);
    ini_WriteString("Conta", "Senha", senha);
    ini_WriteInt("Conta", "Admin", PlayerAdminLevel[playerid]);
    ini_WriteFloat("Posicao", "X", x);
    ini_WriteFloat("Posicao", "Y", y);
    ini_WriteFloat("Posicao", "Z", z);
    ini_WriteInt("Posicao", "Interior", GetPlayerInterior(playerid));
    ini_WriteInt("Posicao", "VW", GetPlayerVirtualWorld(playerid));
    ini_Close();

    LastX[playerid] = x;
    LastY[playerid] = y;
    LastZ[playerid] = z;
    LastInterior[playerid] = GetPlayerInterior(playerid);
    LastVW[playerid] = GetPlayerVirtualWorld(playerid);
}

stock CarregarPosicao(playerid)
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    ini_Open(file);
    LastX[playerid] = ini_ReadFloat("Posicao", "X", 0.0);
    LastY[playerid] = ini_ReadFloat("Posicao", "Y", 0.0);
    LastZ[playerid] = ini_ReadFloat("Posicao", "Z", 0.0);
    LastInterior[playerid] = ini_ReadInt("Posicao", "Interior", 0);
    LastVW[playerid] = ini_ReadInt("Posicao", "VW", 0);
    ini_Close();
}

// =====================
// FILTERSCRIPT
// =====================
public OnFilterScriptInit()
{
    print("[CMD] Sistema de Login/Admin carregado com ini.inc");
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
    if (LastX[playerid] != 0.0 || LastY[playerid] != 0.0 || LastZ[playerid] != 0.0)
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
// COMANDO SALVAR POSIÇÃO
// =====================
CMD:savepos(playerid, params[])
{
    if (!Logado[playerid])
        return SendClientMessage(playerid, COR_VERMELHO, "Você precisa estar logado para salvar sua posição.");

    SalvarPosicao(playerid);
    SendClientMessage(playerid, COR_VERDE, "Posição salva com sucesso!");
    return 1;
}

// =====================
// SALVAR POSIÇÃO AUTOMÁTICA
// =====================
public OnPlayerDeath(playerid, killerid, reason)
{
    SalvarPosicao(playerid);
    return 1;
}

public OnPlayerInteriorChange(playerid, newinterior, oldinterior)
{
    SalvarPosicao(playerid);
    return 1;
}

public OnPlayerVirtualWorldChange(playerid, oldworld, newworld)
{
    SalvarPosicao(playerid);
    return 1;
}
