#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <dini>
#include <streamer>

#define MAX_HOUSES 500

#define COR_VERDE   0x00FF00FF
#define COR_VERMELHO 0xFF0000FF
#define COR_BRANCO  0xFFFFFFFF
#define COR_AMARELO 0xFFFF00FF

// ================= LOGIN =================
#define DIALOG_LOGIN    1
#define DIALOG_REGISTER 2
#define USER_PATH "scriptfiles/contas/%s.ini"

new bool:Logado[MAX_PLAYERS];
new PlayerAdminLevel[MAX_PLAYERS];
new UltimaCasa[MAX_PLAYERS];

// ================= CASAS =================
new bool:HouseExists[MAX_HOUSES];
new HouseOwner[MAX_HOUSES];
new Float:HouseX[MAX_HOUSES];
new Float:HouseY[MAX_HOUSES];
new Float:HouseZ[MAX_HOUSES];
new Float:HouseIX[MAX_HOUSES];
new Float:HouseIY[MAX_HOUSES];
new Float:HouseIZ[MAX_HOUSES];
new HouseInterior[MAX_HOUSES];
new HousePrice[MAX_HOUSES];
new HouseLocked[MAX_HOUSES];

new HousePickup[MAX_HOUSES];
new Text3D:HouseLabel[MAX_HOUSES];

// ================= FUNÇÕES =================
stock GetUserFile(playerid, dest[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof nome);
    format(dest, size, USER_PATH, nome);
}

stock GetHouseFile(houseid, dest[], size)
{
    format(dest, size, "scriptfiles/houses/%d.ini", houseid);
}

// ================= LOGIN =================
stock Registrar(playerid, senha[])
{
    new file[64];
    GetUserFile(playerid, file, sizeof file);
    dini_Create(file);
    dini_Set(file, "Senha", senha);
    dini_IntSet(file, "Admin", 0);
}

stock bool:ChecarSenha(playerid, senha[])
{
    new file[64], saved[64];
    GetUserFile(playerid, file, sizeof file);
    format(saved, sizeof saved, "%s", dini_Get(file, "Senha"));
    return !strcmp(saved, senha);
}

// ================= CASAS =================
stock AtualizarCasa(h)
{
    if (!HouseExists[h]) return;

    new texto[128];
    if (HouseOwner[h] == -1)
        format(texto, sizeof texto, "Casa %d\nPreço: $%d\n/use /buyhouse", h, HousePrice[h]);
    else
        format(texto, sizeof texto, "Casa %d\n/use /enterhouse", h);

    SetDynamic3DTextLabelText(HouseLabel[h], COR_VERDE, texto);
}

stock CriarCasa(h)
{
    HousePickup[h] = CreateDynamicPickup(1273, 1, HouseX[h], HouseY[h], HouseZ[h]);
    HouseLabel[h] = CreateDynamic3DTextLabel("Casa", COR_VERDE,
        HouseX[h], HouseY[h], HouseZ[h] + 1.0, 15.0);
    AtualizarCasa(h);
}

stock SalvarCasa(h)
{
    new file[64];
    GetHouseFile(h, file, sizeof file);

    dini_Create(file);
    dini_IntSet(file, "Owner", HouseOwner[h]);
    dini_IntSet(file, "Price", HousePrice[h]);
    dini_IntSet(file, "Locked", HouseLocked[h]);
    dini_FloatSet(file, "X", HouseX[h]);
    dini_FloatSet(file, "Y", HouseY[h]);
    dini_FloatSet(file, "Z", HouseZ[h]);
    dini_FloatSet(file, "IX", HouseIX[h]);
    dini_FloatSet(file, "IY", HouseIY[h]);
    dini_FloatSet(file, "IZ", HouseIZ[h]);
    dini_IntSet(file, "Interior", HouseInterior[h]);
}

stock CarregarCasas()
{
    for (new i; i < MAX_HOUSES; i++)
    {
        new file[64];
        GetHouseFile(i, file, sizeof file);
        if (!dini_Exists(file)) continue;

        HouseExists[i] = true;
        HouseOwner[i] = dini_Int(file, "Owner");
        HousePrice[i] = dini_Int(file, "Price");
        HouseLocked[i] = dini_Int(file, "Locked");
        HouseX[i] = dini_Float(file, "X");
        HouseY[i] = dini_Float(file, "Y");
        HouseZ[i] = dini_Float(file, "Z");
        HouseIX[i] = dini_Float(file, "IX");
        HouseIY[i] = dini_Float(file, "IY");
        HouseIZ[i] = dini_Float(file, "IZ");
        HouseInterior[i] = dini_Int(file, "Interior");

        CriarCasa(i);
    }
}

// ================= CALLBACKS =================
public OnFilterScriptInit()
{
    print("[CASAS] Sistema carregado");
    CarregarCasas();
    return 1;
}

public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    PlayerAdminLevel[playerid] = 0;
    UltimaCasa[playerid] = -1;

    new file[64];
    GetUserFile(playerid, file, sizeof file);

    if (dini_Exists(file))
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
            "Login", "Digite sua senha:", "Entrar", "Sair");
    else
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
            "Registro", "Crie uma senha:", "Registrar", "Sair");
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (!response) return Kick(playerid);

    if (dialogid == DIALOG_REGISTER)
    {
        Registrar(playerid, inputtext);
        Logado[playerid] = true;
        SpawnPlayer(playerid);
        return 1;
    }

    if (dialogid == DIALOG_LOGIN)
    {
        if (!ChecarSenha(playerid, inputtext)) return Kick(playerid);
        Logado[playerid] = true;
        SpawnPlayer(playerid);
        return 1;
    }
    return 1;
}

// ================= COMANDOS =================
CMD:sethouse(playerid, params[])
{
    if (PlayerAdminLevel[playerid] < 5)
        return SendClientMessage(playerid, COR_VERMELHO, "Sem permissão.");

    new id, preco;
    if (sscanf(params, "ii", id, preco))
        return SendClientMessage(playerid, COR_AMARELO, "/sethouse [id] [preço]");

    GetPlayerPos(playerid, HouseX[id], HouseY[id], HouseZ[id]);
    HouseIX[id] = 223.0;
    HouseIY[id] = 1287.0;
    HouseIZ[id] = 1082.1;
    HouseInterior[id] = 1;

    HousePrice[id] = preco;
    HouseOwner[id] = -1;
    HouseLocked[id] = 1;
    HouseExists[id] = true;

    CriarCasa(id);
    SalvarCasa(id);

    SendClientMessage(playerid, COR_VERDE, "Casa criada!");
    return 1;
}

CMD:buyhouse(playerid, params[])
{
    for (new i; i < MAX_HOUSES; i++)
    {
        if (!HouseExists[i] || HouseOwner[i] != -1) continue;
        if (!IsPlayerInRangeOfPoint(playerid, 2.0, HouseX[i], HouseY[i], HouseZ[i])) continue;

        GivePlayerMoney(playerid, -HousePrice[i]);
        HouseOwner[i] = playerid;
        SalvarCasa(i);
        AtualizarCasa(i);
        return SendClientMessage(playerid, COR_VERDE, "Casa comprada!");
    }
    return 1;
}

CMD:enterhouse(playerid, params[])
{
    for (new i; i < MAX_HOUSES; i++)
    {
        if (!HouseExists[i]) continue;
        if (!IsPlayerInRangeOfPoint(playerid, 2.0, HouseX[i], HouseY[i], HouseZ[i])) continue;

        if (HouseLocked[i] && HouseOwner[i] != playerid)
            return SendClientMessage(playerid, COR_VERMELHO, "Casa trancada.");

        SetPlayerInterior(playerid, HouseInterior[i]);
        SetPlayerPos(playerid, HouseIX[i], HouseIY[i], HouseIZ[i]);
        UltimaCasa[playerid] = i;
        return 1;
    }
    return 1;
}

CMD:sellhouse(playerid, params[])
{
    for (new i; i < MAX_HOUSES; i++)
    {
        if (HouseOwner[i] != playerid) continue;

        HouseOwner[i] = -1;
        GivePlayerMoney(playerid, HousePrice[i] / 2);
        SalvarCasa(i);
        AtualizarCasa(i);
        return SendClientMessage(playerid, COR_VERDE, "Casa vendida.");
    }
    return 1;
}
