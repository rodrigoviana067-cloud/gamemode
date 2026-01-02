#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <dini>

#define MAX_HOUSES 500
#define HOUSE_PRICE 50000

enum hInfo
{
    Float:hX,
    Float:hY,
    Float:hZ,
    Float:hIntX,
    Float:hIntY,
    Float:hIntZ,
    hInterior,
    hOwner[MAX_PLAYER_NAME],
    hLocked,
    Text3D:hLabel,
    hPickup
};

new House[MAX_HOUSES][hInfo];

// ================= PATH ===================
stock HouseFile(id, string[], size)
{
    format(string, size, "houses/house_%d.ini", id);
}

// ================= INIT ===================
public OnFilterScriptInit()
{
    print(">> Sistema de Casas 2026 carregando...");
    // Criar a pasta automaticamente via script não é possível em todas as versões, 
    // certifique-se que a pasta 'scriptfiles/houses' existe.
    
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        LoadHouse(i);
    }
    return 1;
}

// ================= CARREGAR CASA =============
LoadHouse(id)
{
    new file[64];
    HouseFile(id, file, sizeof file);

    if(!dini_Exists(file)) return 0;

    House[id][hX] = dini_Float(file, "X");
    House[id][hY] = dini_Float(file, "Y");
    House[id][hZ] = dini_Float(file, "Z");
    House[id][hIntX] = dini_Float(file, "IX");
    House[id][hIntY] = dini_Float(file, "IY");
    House[id][hIntZ] = dini_Float(file, "IZ");
    House[id][hInterior] = dini_Int(file, "Interior");
    
    format(House[id][hOwner], MAX_PLAYER_NAME, "%s", dini_Get(file, "Owner"));
    House[id][hLocked] = dini_Int(file, "Locked");

    if(House[id][hLabel] != Text3D:0) DestroyDynamic3DTextLabel(House[id][hLabel]);
    if(House[id][hPickup] != 0) DestroyDynamicPickup(House[id][hPickup]);

    new labelStr[128];
    if(!strcmp(House[id][hOwner], "Ninguem", true)) 
    {
        format(labelStr, sizeof labelStr, "{00FF00}Casa à venda\n{FFFFFF}Preço: {00FF00}$%d\n{FFFFFF}/buyhouse", HOUSE_PRICE);
        House[id][hPickup] = CreateDynamicPickup(1273, 1, House[id][hX], House[id][hY], House[id][hZ]);
        House[id][hLabel] = CreateDynamic3DTextLabel(labelStr, -1, House[id][hX], House[id][hY], House[id][hZ] + 0.8, 10.0);
    }
    else 
    {
        format(labelStr, sizeof labelStr, "{00CCFF}Casa de: {FFFFFF}%s\n{00CCFF}Status: %s\n{FFFFFF}/enterhouse", House[id][hOwner], (House[id][hLocked] ? "{FF0000}Trancada" : "{00FF00}Aberta"));
        House[id][hPickup] = CreateDynamicPickup(1272, 1, House[id][hX], House[id][hY], House[id][hZ]);
        House[id][hLabel] = CreateDynamic3DTextLabel(labelStr, -1, House[id][hX], House[id][hY], House[id][hZ] + 0.8, 10.0);
    }
    return 1;
}

// ================= SALVAR CASA =============
SaveHouse(id)
{
    new file[64];
    HouseFile(id, file, sizeof file);

    if(!dini_Exists(file)) dini_Create(file);

    dini_FloatSet(file, "X", House[id][hX]);
    dini_FloatSet(file, "Y", House[id][hY]);
    dini_FloatSet(file, "Z", House[id][hZ]);
    dini_FloatSet(file, "IX", House[id][hIntX]);
    dini_FloatSet(file, "IY", House[id][hIntY]);
    dini_FloatSet(file, "IZ", House[id][hIntZ]);
    dini_IntSet(file, "Interior", House[id][hInterior]);
    dini_Set(file, "Owner", House[id][hOwner]);
    dini_IntSet(file, "Locked", House[id][hLocked]);
    return 1;
}

// ================= COMANDOS =============

CMD:sethouse(playerid, params[])
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "Apenas admins RCON.");
    new id;
    if(sscanf(params, "d", id)) return SendClientMessage(playerid, -1, "Use: /sethouse [ID]");
    if(id < 0 || id >= MAX_HOUSES) return SendClientMessage(playerid, -1, "ID Inválido.");

    GetPlayerPos(playerid, House[id][hX], House[id][hY], House[id][hZ]);
    House[id][hIntX] = House[id][hX];
    House[id][hIntY] = House[id][hY];
    House[id][hIntZ] = House[id][hZ];
    House[id][hInterior] = GetPlayerInterior(playerid);
    format(House[id][hOwner], MAX_PLAYER_NAME, "Ninguem");
    House[id][hLocked] = 0;

    SaveHouse(id);
    LoadHouse(id);
    SendClientMessage(playerid, -1, "Casa criada! Agora configure o interior no arquivo .ini ou use um comando de /sethpoint.");
    return 1;
}

CMD:buyhouse(playerid, params[])
{
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 2.0, House[i][hX], House[i][hY], House[i][hZ]))
        {
            if(strcmp(House[i][hOwner], "Ninguem", true)) return SendClientMessage(playerid, -1, "Já tem dono.");
            if(GetPlayerMoney(playerid) < HOUSE_PRICE) return SendClientMessage(playerid, -1, "Sem grana.");

            new name[MAX_PLAYER_NAME];
            GetPlayerName(playerid, name, sizeof(name));
            GivePlayerMoney(playerid, -HOUSE_PRICE);
            format(House[i][hOwner], MAX_PLAYER_NAME, "%s", name);
            House[i][hLocked] = 1;
            SaveHouse(i);
            LoadHouse(i);
            SendClientMessage(playerid, -1, "Casa comprada!");
            return 1;
        }
    }
    return 1;
}

CMD:lockhouse(playerid, params[])
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 3.0, House[i][hX], House[i][hY], House[i][hZ]))
        {
            if(strcmp(House[i][hOwner], name, true)) return SendClientMessage(playerid, -1, "Não é sua.");
            House[i][hLocked] = !House[i][hLocked];
            SaveHouse(i);
            LoadHouse(i);
            SendClientMessage(playerid, -1, House[i][hLocked] ? "Trancada." : "Aberta.");
            return 1;
        }
    }
    return 1;
}

CMD:enterhouse(playerid, params[])
{
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 2.0, House[i][hX], House[i][hY], House[i][hZ]))
        {
            if(House[i][hLocked]) return SendClientMessage(playerid, -1, "Trancada.");
            SetPlayerInterior(playerid, House[i][hInterior]);
            SetPlayerPos(playerid, House[i][hIntX], House[i][hIntY], House[i][hIntZ]);
            return 1;
        }
    }
    return 1;
}

CMD:exithouse(playerid, params[])
{
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 5.0, House[i][hIntX], House[i][hIntY], House[i][hIntZ]))
        {
            SetPlayerInterior(playerid, 0);
            SetPlayerPos(playerid, House[i][hX], House[i][hY], House[i][hZ]);
            return 1;
        }
    }
    return 1;
}
