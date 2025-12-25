#include <a_samp>
#include <zcmd>
#include <sscanf2>

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
    new File:f;
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    f = fopen(file, io_write);
    if (!f) return 0;

    fprintf(f, "Senha=%s\r\n", senha);
    fprintf(f, "Admin=0\r\n");
    fclose(f);
    return 1;
}

// =====================
// CHECAR SENHA
// =====================
stock bool:ChecarSenha(playerid, const senha[])
{
    new File:f;
    new file[64], linha[128];
    GetUserFile(playerid, file, sizeof(file));

    f = fopen(file, io_read);
    if (!f) return false;

    while (fread(f, linha))
    {
        if (strn_cmp(linha, "Senha=", 6))
        {
            new saved[64];
            strmid(saved, linha, 6, strlen(linha)-1);
            fclose(f);
            return !strcmp(saved, senha);
        }
    }
    fclose(f);
    return false;
}

// =====================
// ADMIN
// =====================
stock CarregarAdmin(playerid)
{
    new File:f;
    new file[64], linha[64];
    GetUserFile(playerid, file, sizeof(file));

    f = fopen(file, io_read);
    if (!f) return;

    while (fread(f, linha))
    {
        if (strn_cmp(linha, "Admin=", 6))
        {
            PlayerAdminLevel[playerid] = strval(linha[6]);
            break;
        }
    }
    fclose(f);
}

stock SalvarAdmin(playerid)
{
    new File:f;
    new file[64], senha[64];
    GetUserFile(playerid, file, sizeof(file));

    if (!GetSenhaSalva(playerid, senha, sizeof(senha))) return;

    f = fopen(file, io_write);
    if (!f) return;

    fprintf(f, "Senha=%s\r\n", senha);
    fprintf(f, "Admin=%d\r\n", PlayerAdminLevel[playerid]);
    fclose(f);
}

// =====================
// SENHA
// =====================
stock GetSenhaSalva(playerid, senha[], size)
{
    new File:f;
    new file[64], linha[128];
    GetUserFile(playerid, file, sizeof(file));

    f = fopen(file, io_read);
    if (!f) return 0;

    while (fread(f, linha))
    {
        if (strn_cmp(linha, "Senha=", 6))
        {
            strmid(senha, linha, 6, strlen(linha)-1);
            fclose(f);
            return 1;
        }
    }
    fclose(f);
    return 0;
}

// =====================
// POSIÇÃO
// =====================
stock SalvarPosicao(playerid)
{
    if (!Logado[playerid]) return;

    new File:f;
    new file[64], senha[64];
    GetUserFile(playerid, file, sizeof(file));
    if (!GetSenhaSalva(playerid, senha, sizeof(senha))) return;

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    f = fopen(file, io_write);
    if (!f) return;

    fprintf(f, "Senha=%s\r\n", senha);
    fprintf(f, "Admin=%d\r\n", PlayerAdminLevel[playerid]);
    fprintf(f, "X=%f\r\nY=%f\r\nZ=%f\r\n", x, y, z);
    fprintf(f, "Interior=%d\r\nVW=%d\r\n",
        GetPlayerInterior(playerid),
        GetPlayerVirtualWorld(playerid)
    );
    fclose(f);

    // Atualiza variáveis do servidor
    LastX[playerid] = x;
    LastY[playerid] = y;
    LastZ[playerid] = z;
    LastInterior[playerid] = GetPlayerInterior(playerid);
    LastVW[playerid] = GetPlayerVirtualWorld(playerid);
}

stock CarregarPosicao(playerid)
{
    new File:f;
    new file[64], linha[128];
    GetUserFile(playerid, file, sizeof(file));

    f = fopen(file, io_read);
    if (!f) return;

    while (fread(f, linha))
    {
        if (strn_cmp(linha, "X=", 2)) LastX[playerid] = floatstr(linha[2]);
        else if (strn_cmp(linha, "Y=", 2)) LastY[playerid] = floatstr(linha[2]);
        else if (strn_cmp(linha, "Z=", 2)) LastZ[playerid] = floatstr(linha[2]);
        else if (strn_cmp(linha, "Interior=", 9)) LastInterior[playerid] = strval(linha[9]);
        else if (strn_cmp(linha, "VW=", 3)) LastVW[playerid] = strval(linha[3]);
    }
    fclose(f);
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
