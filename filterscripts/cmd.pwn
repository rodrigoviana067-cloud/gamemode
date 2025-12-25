#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <simple_ini>
#include <string>
#include <float>
#include <streamer> // Para 3DText e pickups

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
#define CASA_PATH "scriptfiles/casas/%d.ini"

// =====================
// VARIÁVEIS GLOBAIS
// =====================
new bool:Logado[MAX_PLAYERS];
new PlayerAdminLevel[MAX_PLAYERS];

new Float:LastX[MAX_PLAYERS];
new Float:LastY[MAX_PLAYERS];
new Float:LastZ[MAX_PLAYERS];
new LastInterior[MAX_PLAYERS];
new LastVW[MAX_PLAYERS];

new CasaLabel[MAX_PLAYERS];      // 3DText do player
new CasaPickup[MAX_PLAYERS];     // Pickup da porta da casa
new CasaID[MAX_PLAYERS];         // Última casa que entrou

new CasaOwner[100];              // ID do player dono da casa (exemplo: 100 casas)
new Float:CasaX[100];
new Float:CasaY[100];
new Float:CasaZ[100];
new CasaInterior[100];
new CasaPreco[100];
new bool:CasaTrancada[100];

// =====================
// FUNÇÕES AUXILIARES
// =====================
stock GetUserFile(playerid, dest[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(dest, size, USER_PATH, nome);
}

stock GetCasaFile(id, dest[], size)
{
    format(dest, size, CASA_PATH, id);
}

// =====================
// REGISTRO / LOGIN
// =====================
stock RegistrarConta(playerid, const senha[])
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    WriteINIString(file, "Conta", "Senha", senha);
    WriteINIInt(file, "Conta", "Admin", 0);
    return 1;
}

stock bool:ChecarSenha(playerid, const senha[])
{
    new file[64], saved[64];
    GetUserFile(playerid, file, sizeof(file));

    ReadINIString(file, "Conta", "Senha", "", saved, sizeof(saved));
    return strcmp(saved, senha) == 0;
}

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
// POSIÇÃO DO PLAYER
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
// CASA
// =====================
stock CriarCasa(id, Float:x, Float:y, Float:z, interior, preco)
{
    CasaX[id] = x;
    CasaY[id] = y;
    CasaZ[id] = z;
    CasaInterior[id] = interior;
    CasaPreco[id] = preco;
    CasaTrancada[id] = true;
    CasaOwner[id] = -1;
}

stock ComprarCasa(playerid, id)
{
    if (CasaOwner[id] != -1) {
        SendClientMessage(playerid, COR_VERMELHO, "Esta casa já tem dono!");
        return 0;
    }
    new Float:money;
    GetPlayerMoney(playerid, money);
    if (money < CasaPreco[id]) {
        SendClientMessage(playerid, COR_VERMELHO, "Você não tem dinheiro suficiente!");
        return 0;
    }

    TakePlayerMoney(playerid, CasaPreco[id]);
    CasaOwner[id] = playerid;
    SendClientMessage(playerid, COR_VERDE, "Você comprou a casa!");
    return 1;
}

stock EntrarCasa(playerid, id)
{
    if (CasaTrancada[id] && CasaOwner[id] != playerid) {
        SendClientMessage(playerid, COR_VERMELHO, "Casa trancada!");
        return 0;
    }

    SetPlayerInterior(playerid, CasaInterior[id]);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, CasaX[id], CasaY[id], CasaZ[id]);

    CasaID[playerid] = id;
    return 1;
}

stock TrancarCasa(playerid, id)
{
    if (CasaOwner[id] != playerid) return 0;
    CasaTrancada[id] = true;
    UpdateCasaLabel(id);
    return 1;
}

stock DestrancarCasa(playerid, id)
{
    if (CasaOwner[id] != playerid) return 0;
    CasaTrancada[id] = false;
    UpdateCasaLabel(id);
    return 1;
}

stock UpdateCasaLabel(id)
{
    if (CasaLabel[id] != INVALID_3DTEXT) {
        SetDynamic3DTextLabelText(CasaLabel[id], CasaTrancada[id] ? "Casa trancada" : "Casa destrancada");
    }
}

// =====================
// EVENTS
// =====================
public OnFilterScriptInit()
{
    print("[CMD] Sistema de Login/Admin e Casas carregado");
    
    // Exemplo: criar casas fixas
    CriarCasa(0, 1500.0, -1700.0, 13.0, 1, 50000);
    CriarCasa(1, 1505.0, -1705.0, 13.0, 2, 75000);
    return 1;
}

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

public OnPlayerDisconnect(playerid, reason)
{
    SalvarPosicao(playerid);
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
