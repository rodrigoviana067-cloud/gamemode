#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <dini>

// ================= CONFIG =================
#define MAX_HOUSES 500
#define HOUSE_PRICE 50000

// ================= ENUM ===================
enum hInfo
{
    Float:hX,
    Float:hY,
    Float:hZ,
    Float:hIntX,
    Float:hIntY,
    Float:hIntZ,
    hInterior,
    hOwner,
    hLocked,
    Text3D:hLabel,
    Pickup:hPickup
};

new House[MAX_HOUSES][hInfo];
new PlayerHouse[MAX_PLAYERS] = {-1, ...};

// ================= PATH ===================
stock HouseFile(id, string[], size)
{
    format(string, size, "houses/house_%d.ini", id);
}

// ================= LOAD HOUSE =============
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
    House[id][hOwner] = dini_Int(file, "Owner");
    House[id][hLocked] = dini_Int(file, "Locked");

    new label[128];
    if(House[id][hOwner] == -1)
        format(label, sizeof label, "Casa à venda\nPreço: $%d", HOUSE_PRICE);
    else
        format(label, sizeof label, "Casa privada");

    House[id][hPickup] = CreateDynamicPickup(
        1273, 23,
        House[id][hX], House[id][hY], House[id][hZ]
    );

    House[id][hLabel] = CreateDynamic3DTextLabel(
        label, 0x00FF00FF,
        House[id][hX], House[id][hY], House[id][hZ] + 1.0,
        10.0
    );

    return 1;
}

// ================= SAVE HOUSE =============
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
    dini_IntSet(file, "Owner", House[id][hOwner]);
    dini_IntSet(file, "Locked", House[id][hLocked]);
}

// ================= CREATE HOUSE (ADMIN) ===
CMD:sethouse(playerid, params[])
{
    new id;
    if(sscanf(params, "d", id)) return SendClientMessage(playerid, -1, "/sethouse ID");

    if(id < 0 || id >= MAX_HOUSES) return SendClientMessage(playerid, -1, "ID inválido");

    GetPlayerPos(playerid, House[id][hX], House[id][hY], House[id][hZ]);
    GetPlayerPos(playerid, House[id][hIntX], House[id][hIntY], House[id][hIntZ]);

    House[id][hInterior] = GetPlayerInterior(playerid);
    House[id][hOwner] = -1;
    House[id][hLocked] = 1;

    SaveHouse(id);
    LoadHouse(id);

    SendClientMessage(playerid, -1, "Casa criada com sucesso.");
    return 1;
}

// ================= BUY HOUSE ==============
CMD:buyhouse(playerid, params[])
{
    for(new i; i < MAX_HOUSES; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 2.0,
            House[i][hX], House[i][hY], House[i][hZ]))
        {
            if(House[i][hOwner] != -1)
                return SendClientMessage(playerid, -1, "Essa casa já tem dono.");

            if(GetPlayerMoney(playerid) < HOUSE_PRICE)
                return SendClientMessage(playerid, -1, "Dinheiro insuficiente.");

            GivePlayerMoney(playerid, -HOUSE_PRICE);
            House[i][hOwner] = playerid;
            PlayerHouse[playerid] = i;

            SaveHouse(i);

            SetDynamic3DTextLabelText(
                House[i][hLabel],
                0xFF0000FF,
                "Casa privada"
            );

            SendClientMessage(playerid, -1, "Você comprou a casa!");
            return 1;
        }
    }
    return SendClientMessage(playerid, -1, "Você não está perto de nenhuma casa.");
}

// ================= ENTER HOUSE ============
CMD:enterhouse(playerid, params[])
{
    new id = PlayerHouse[playerid];
    if(id == -1) return SendClientMessage(playerid, -1, "Você não tem casa.");

    if(House[id][hLocked])
        return SendClientMessage(playerid, -1, "Casa trancada.");

    SetPlayerInterior(playerid, House[id][hInterior]);
    SetPlayerPos(playerid,
        House[id][hIntX],
        House[id][hIntY],
        House[id][hIntZ]
    );
    return 1;
}

// ================= SELL HOUSE =============
CMD:sellhouse(playerid, params[])
{
    new id = PlayerHouse[playerid];
    if(id == -1) return SendClientMessage(playerid, -1, "Você não tem casa.");

    House[id][hOwner] = -1;
    PlayerHouse[playerid] = -1;

    GivePlayerMoney(playerid, HOUSE_PRICE / 2);

    SetDynamic3DTextLabelText(
        House[id][hLabel],
        0x00FF00FF,
        "Casa à venda"
    );

    SaveHouse(id);
    SendClientMessage(playerid, -1, "Casa vendida.");
    return 1;
}
