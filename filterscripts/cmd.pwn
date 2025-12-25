#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <dini.inc>
#include <float>
#include <string>

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
// VARIÁVEIS
// =====================
new bool:Logado[MAX_PLAYERS];
new PlayerAdminLevel[MAX_PLAYERS];

new Float:LastX[MAX_PLAYERS];
new Float:LastY[MAX_PLAYERS];
new Float:LastZ[MAX_PLAYERS];
new LastInterior[MAX_PLAYERS];
new LastVW[MAX_PLAYERS];

new CasaOwner[100]; // ID da conta que possui a casa
new CasaLocked[100];
new Float:CasaX[100], CasaY[100], CasaZ[100];
new CasaInterior[100];
new CasaPickup[100]; // pickup ID
new CasaLabel[100];  // 3DText ID
new CasaPreco[100];

// =====================
// FUNÇÕES AUX
// =====================
stock GetUserFile(playerid, dest[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(dest, size, USER_PATH, nome);
}

stock TakePlayerMoney(playerid, amount)
{
    new money;
    GetPlayerMoney(playerid, money);
    if (money < amount) return false;
    GivePlayerMoney(playerid, -amount);
    return true;
}

// =====================
// REGISTRO
// =====================
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
    strcopy(saved, sizeof(saved), dini_Get(file, "Senha"));
    return strcmp(saved, senha) == 0;
}

// =====================
// ADMIN
// =====================
stock CarregarAdmin(playerid)
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));
    PlayerAdminLevel[playerid] = dini_Int(file, "Admin");
}

stock SalvarAdmin(playerid)
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));
    dini_IntSet(file, "Admin", PlayerAdminLevel[playerid]);
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

// =====================
// CASA
// =====================
stock CriarCasa(id, Float:x, Float:y, Float:z, interior, preco)
{
    CasaX[id] = x;
    CasaY[id] = y;
    CasaZ[id] = z;
    CasaInterior[id] = interior;
    CasaLocked[id] = true;
    CasaOwner[id] = -1;
    CasaPreco[id] = preco;

    CasaLabel[id] = CreateDynamic3DTextLabel("Casa trancada", x, y, z + 1.0, 10.0, COR_VERMELHO, -1, 0);
    CasaPickup[id] = CreatePickup(x, y, z, 1272, 1, id);
}

// =====================
// FILTERSCRIPT INIT
// =====================
public OnFilterScriptInit()
{
    print("[CMD] Sistema de Login/Admin/Casas carregado");

    // Exemplo de casas
    CriarCasa(0, 1529.6, -1691.2, 13.3, 1, 50000);
    CriarCasa(1, 1570.0, -1675.0, 13.3, 1, 75000);
    return 1;
}

// =====================
// PLAYER CONNECT
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

// =====================
// PLAYER DISCONNECT
// =====================
public OnPlayerDisconnect(playerid, reason)
{
    SalvarPosicao(playerid);
    return 1;
}

// =====================
// PLAYER SPAWN
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
// DIALOG RESPONSE
// =====================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (!response) return Kick(playerid);

    if (dialogid == DIALOG_REGISTRO)
    {
        if (strlen(inputtext) < 3)
        {
            return ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD,
                "Registro", "Senha muito curta!", "Registrar", "Sair");
        }

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
// PICKUP EVENT (ENTRAR/COMPRAR CASA)
// =====================
public OnPlayerPickUpPickup(playerid, pickupid)
{
    for (new i = 0; i < 100; i++)
    {
        if (CasaPickup[i] == pickupid)
        {
            if (CasaOwner[i] == -1)
            {
                // Comprar casa
                if (!TakePlayerMoney(playerid, CasaPreco[i]))
                {
                    SendClientMessage(playerid, COR_VERMELHO, "Você não tem dinheiro para comprar esta casa.");
                    return 1;
                }
                CasaOwner[i] = playerid;
                CasaLocked[i] = true;
                SetDynamic3DTextLabelText(CasaLabel[i], "Casa trancada");
                SendClientMessage(playerid, COR_VERDE, "Casa comprada com sucesso!");
            }
            else if (CasaOwner[i] == playerid)
            {
                // Entrar/Trancar casa
                if (CasaLocked[i])
                {
                    CasaLocked[i] = false;
                    SetPlayerInterior(playerid, CasaInterior[i]);
                    SetPlayerPos(playerid, CasaX[i], CasaY[i], CasaZ[i]);
                    SetDynamic3DTextLabelText(CasaLabel[i], "Casa destrancada");
                    SendClientMessage(playerid, COR_VERDE, "Casa destrancada. Você entrou.");
                }
                else
                {
                    CasaLocked[i] = true;
                    SetPlayerPos(playerid, CasaX[i], CasaY[i], CasaZ[i]);
                    SetPlayerInterior(playerid, 0);
                    SetDynamic3DTextLabelText(CasaLabel[i], "Casa trancada");
                    SendClientMessage(playerid, COR_AMARELO, "Casa trancada.");
                }
            }
            else
            {
                SendClientMessage(playerid, COR_VERMELHO, "Esta casa não é sua.");
            }
            return 1;
        }
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
