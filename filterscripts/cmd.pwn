new PlayerAdminLevel[MAX_PLAYERS];
#include <a_samp>
#include <zcmd>
#include <sscanf2>
#define MAX_CASAS 50

enum cInfo {
    Float:cX,
    Float:cY,
    Float:cZ,
    Float:cIX,
    Float:cIY,
    Float:cIZ,
    cInterior,
    cPreco,
    bool:cVendida,
    cDono[MAX_PLAYER_NAME]
};

new Casa[MAX_CASAS][cInfo];

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
// VARIÁVEIS
// =====================
new bool:Logado[MAX_PLAYERS];
new PlayerAdmin[MAX_PLAYERS];
new SenhaPlayer[MAX_PLAYERS][32];

// =====================
// PATH
// =====================
stock GetUserFile(playerid, dest[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(dest, size, "scriptfiles/contas/%s.ini", nome);
}

// =====================
// REGISTRAR
// =====================
stock RegistrarConta(playerid, senha[])
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    new File:f = fopen(file, io_write);
    if (!f) return 0;

    new linha[128];
    format(linha, sizeof(linha), "Senha=%s\r\nAdmin=0\r\n", senha);
    fwrite(f, linha);
    fclose(f);

    return 1;
}

// =====================
// CARREGAR CONTA
// =====================
stock SalvarCasa(id)
{
    new file[64];
    CasaPath(id, file, sizeof(file));

    dini_Create(file);
    dini_FloatSet(file, "X", Casa[id][cX]);
    dini_FloatSet(file, "Y", Casa[id][cY]);
    dini_FloatSet(file, "Z", Casa[id][cZ]);

    dini_FloatSet(file, "IX", Casa[id][cIX]);
    dini_FloatSet(file, "IY", Casa[id][cIY]);
    dini_FloatSet(file, "IZ", Casa[id][cIZ]);
    dini_IntSet(file, "Interior", Casa[id][cInterior]);

    dini_IntSet(file, "Preco", Casa[id][cPreco]);
    dini_IntSet(file, "Vendida", Casa[id][cVendida]);
    dini_Set(file, "Dono", Casa[id][cDono]);
}

stock CasaPath(id, dest[], size)
{
    format(dest, size, "scriptfiles/casas/casa_%d.ini", id);
}

stock CarregarConta(playerid)
{
    new file[64];
    GetUserFile(playerid, file, sizeof(file));
    if (!fexist(file)) return 0;

    new File:f = fopen(file, io_read);
    if (!f) return 0;

    new linha[128];
    while (fread(f, linha))
    {
        if (strfind(linha, "Senha=", true) != -1)
        {
            strmid(SenhaPlayer[playerid], linha, 6, strlen(linha), sizeof(SenhaPlayer[]));
        }
        if (strfind(linha, "Admin=", true) != -1)
        {
            PlayerAdmin[playerid] = strval(linha[6]);
        }
    }
    fclose(f);
    return 1;
}

// =====================
// FILTERSCRIPT INIT
// =====================
stock CarregarCasas()
{
    for (new i = 0; i < MAX_CASAS; i++)
    {
        new file[64];
        CasaPath(i, file, sizeof(file));

        if (!fexist(file)) continue;

        Casa[i][cX] = dini_Float(file, "X");
        Casa[i][cY] = dini_Float(file, "Y");
        Casa[i][cZ] = dini_Float(file, "Z");

        Casa[i][cIX] = dini_Float(file, "IX");
        Casa[i][cIY] = dini_Float(file, "IY");
        Casa[i][cIZ] = dini_Float(file, "IZ");
        Casa[i][cInterior] = dini_Int(file, "Interior");

        Casa[i][cPreco] = dini_Int(file, "Preco");
        Casa[i][cVendida] = dini_Int(file, "Vendida");
        format(Casa[i][cDono], MAX_PLAYER_NAME, dini_Get(file, "Dono"));
    }
}

public OnFilterScriptInit()
{
    CarregarCasas();
    print("[CASAS] Sistema carregado");
    return 1;
}

// =====================
// CONNECT
// =====================
public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    PlayerAdmin[playerid] = 0;

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
        SendClientMessage(playerid, COR_VERDE, "Conta registrada!");
        SpawnPlayer(playerid);
        return 1;
    }

    if (dialogid == DIALOG_LOGIN)
    {
        CarregarConta(playerid);

        if (strcmp(inputtext, SenhaPlayer[playerid], false) != 0)
            return Kick(playerid);

        Logado[playerid] = true;
        SendClientMessage(playerid, COR_VERDE, "Login efetuado!");
        SpawnPlayer(playerid);
        return 1;
    }
    return 1;
}

// =====================
// COMANDO ADMIN
// =====================
CMD:setadmin(playerid, params[])
{
    if (PlayerAdmin[playerid] < 5)
        return SendClientMessage(playerid, COR_VERMELHO, "Sem permissão.");

    new id, nivel;
    if (sscanf(params, "ii", id, nivel))
        return SendClientMessage(playerid, COR_AMARELO, "/setadmin [id] [nivel]");

    PlayerAdmin[id] = nivel;
    SendClientMessage(id, COR_VERDE, "Você recebeu admin!");
    SendClientMessage(playerid, COR_VERDE, "Admin definido.");
    return 1;
}

CMD:criarcasa(playerid, params[])
{
    if (PlayerAdminLevel[playerid] < 5)
        return SendClientMessage(playerid, COR_VERMELHO, "Sem permissão.");

    new preco;
    if (sscanf(params, "i", preco))
        return SendClientMessage(playerid, COR_AMARELO, "/criarcasa [preço]");

    for (new i = 0; i < MAX_CASAS; i++)
    {
        if (Casa[i][cPreco] == 0)
        {
            GetPlayerPos(playerid, Casa[i][cX], Casa[i][cY], Casa[i][cZ]);
            Casa[i][cInterior] = GetPlayerInterior(playerid);
            Casa[i][cIX] = 223.0; // entrada X interna
            Casa[i][cIY] = 1287.0; // entrada Y interna
            Casa[i][cIZ] = 1082.0; // entrada Z interna
            Casa[i][cPreco] = preco;
            Casa[i][cVendida] = false;
            format(Casa[i][cDono], MAX_PLAYER_NAME, "Ninguem");

            SalvarCasa(i);
            SendClientMessage(playerid, COR_VERDE, "Casa criada!");
            return 1;
        }
    }
    return SendClientMessage(playerid, COR_VERMELHO, "Limite de casas atingido.");
}

CMD:comprarcasa(playerid, params[])
{
    for (new i = 0; i < MAX_CASAS; i++)
    {
        if (IsPlayerInRangeOfPoint(playerid, 2.0,
            Casa[i][cX], Casa[i][cY], Casa[i][cZ]) &&
            !Casa[i][cVendida])
        {
            if (GetPlayerMoney(playerid) < Casa[i][cPreco])
                return SendClientMessage(playerid, COR_VERMELHO, "Dinheiro insuficiente.");

            GivePlayerMoney(playerid, -Casa[i][cPreco]);
            GetPlayerName(playerid, Casa[i][cDono], MAX_PLAYER_NAME);
            Casa[i][cVendida] = true;

            SalvarCasa(i);
            SendClientMessage(playerid, COR_VERDE, "Casa comprada com sucesso!");
            return 1;
        }
    }
    return SendClientMessage(playerid, COR_AMARELO, "Você não está em frente a uma casa à venda.");
}

CMD:entrarcasa(playerid, params[])
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));

    for (new i = 0; i < MAX_CASAS; i++)
    {
        if (IsPlayerInRangeOfPoint(playerid, 2.0,
            Casa[i][cX], Casa[i][cY], Casa[i][cZ]))
        {
            if (strcmp(nome, Casa[i][cDono]) != 0)
                return SendClientMessage(playerid, COR_VERMELHO, "Essa casa não é sua.");

            SetPlayerInterior(playerid, Casa[i][cInterior]);
            SetPlayerVirtualWorld(playerid, i + 1); // VW único por casa
            SetPlayerPos(playerid, Casa[i][cIX], Casa[i][cIY], Casa[i][cIZ]);
            return 1;
        }
    }
    return SendClientMessage(playerid, COR_AMARELO, "Você não está em frente a nenhuma casa.");
}

CMD:saircasa(playerid, params[])
{
    for (new i = 0; i < MAX_CASAS; i++)
    {
        if (GetPlayerVirtualWorld(playerid) == i + 1)
        {
            SetPlayerVirtualWorld(playerid, 0);
            SetPlayerInterior(playerid, 0);
            SetPlayerPos(playerid, Casa[i][cX], Casa[i][cY], Casa[i][cZ]);
            return 1;
        }
    }
    return SendClientMessage(playerid, COR_AMARELO, "Você não está dentro de uma casa.");
}
