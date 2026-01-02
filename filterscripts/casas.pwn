#define FILTERSCRIPT
#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <dini>

#define MAX_HOUSES      500
#define HOUSE_PRICE     50000

enum hInfo {
    Float:hX, Float:hY, Float:hZ,
    Float:hIntX, Float:hIntY, Float:hIntZ,
    hInterior, hOwner[MAX_PLAYER_NAME], hLocked,
    Text3D:hLabel, hPickup
};
new House[MAX_HOUSES][hInfo];

stock HouseFile(id, string[], size) { format(string, size, "houses/house_%d.ini", id); }

stock SaveHouse(id) {
    new file[64]; HouseFile(id, file, sizeof file);
    if(!dini_Exists(file)) dini_Create(file);
    dini_FloatSet(file, "X", House[id][hX]); dini_FloatSet(file, "Y", House[id][hY]); dini_FloatSet(file, "Z", House[id][hZ]);
    dini_FloatSet(file, "IX", House[id][hIntX]); dini_FloatSet(file, "IY", House[id][hIntY]); dini_FloatSet(file, "IZ", House[id][hIntZ]);
    dini_IntSet(file, "Interior", House[id][hInterior]); dini_Set(file, "Owner", House[id][hOwner]); dini_IntSet(file, "Locked", House[id][hLocked]);
}

stock LoadHouse(id) {
    new file[64]; HouseFile(id, file, sizeof file);
    if(!dini_Exists(file)) return 0;
    House[id][hX] = dini_Float(file, "X"); House[id][hY] = dini_Float(file, "Y"); House[id][hZ] = dini_Float(file, "Z");
    House[id][hIntX] = dini_Float(file, "IX"); House[id][hIntY] = dini_Float(file, "IY"); House[id][hIntZ] = dini_Float(file, "IZ");
    House[id][hInterior] = dini_Int(file, "Interior");
    format(House[id][hOwner], MAX_PLAYER_NAME, "%s", dini_Get(file, "Owner"));
    House[id][hLocked] = dini_Int(file, "Locked");
    
    if(House[id][hLabel] != Text3D:0) DestroyDynamic3DTextLabel(House[id][hLabel]);
    if(House[id][hPickup] != 0) DestroyDynamicPickup(House[id][hPickup]);

    new str[128];
    if(!strcmp(House[id][hOwner], "Ninguem", true)) {
        format(str, sizeof str, "{00FF00}Casa à Venda\nID: %d\nPreço: $50.000\n/buyhouse", id);
        House[id][hPickup] = CreateDynamicPickup(1273, 1, House[id][hX], House[id][hY], House[id][hZ]);
    } else {
        format(str, sizeof str, "{00CCFF}Casa de: %s\n/enterhouse", House[id][hOwner]);
        House[id][hPickup] = CreateDynamicPickup(1272, 1, House[id][hX], House[id][hY], House[id][hZ]);
    }
    House[id][hLabel] = CreateDynamic3DTextLabel(str, -1, House[id][hX], House[id][hY], House[id][hZ]+0.5, 15.0);
    return 1;
}

public OnFilterScriptInit() {
    for(new i = 0; i < MAX_HOUSES; i++) LoadHouse(i);
    return 1;
}

CMD:sethouse(playerid, params[]) {
    if(!IsPlayerAdmin(playerid)) return 0;
    new id; if(sscanf(params, "d", id)) return SendClientMessage(playerid, -1, "/sethouse [ID]");
    GetPlayerPos(playerid, House[id][hX], House[id][hY], House[id][hZ]);
    House[id][hIntX] = House[id][hX]; House[id][hIntY] = House[id][hY]; House[id][hIntZ] = House[id][hZ];
    House[id][hInterior] = GetPlayerInterior(playerid);
    format(House[id][hOwner], MAX_PLAYER_NAME, "Ninguem");
    SaveHouse(id); LoadHouse(id);
    return 1;
}

CMD:buyhouse(playerid, params[]) {
    for(new i = 0; i < MAX_HOUSES; i++) {
        if(IsPlayerInRangeOfPoint(playerid, 2.5, House[i][hX], House[i][hY], House[i][hZ])) {
            if(strcmp(House[i][hOwner], "Ninguem", true)) return SendClientMessage(playerid, -1, "Já tem dono.");
            if(GetPlayerMoney(playerid) < HOUSE_PRICE) return SendClientMessage(playerid, -1, "Sem dinheiro.");
            GetPlayerName(playerid, House[i][hOwner], MAX_PLAYER_NAME);
            GivePlayerMoney(playerid, -HOUSE_PRICE);
            SaveHouse(i); LoadHouse(i);
            return 1;
        }
    }
    return 1;
}

CMD:enterhouse(playerid, params[]) {
    for(new i = 0; i < MAX_HOUSES; i++) {
        if(IsPlayerInRangeOfPoint(playerid, 2.5, House[i][hX], House[i][hY], House[i][hZ])) {
            SetPlayerInterior(playerid, House[i][hInterior]);
            SetPlayerPos(playerid, House[i][hIntX], House[i][hIntY], House[i][hIntZ]);
            return 1;
        }
    }
    return 1;
}

CMD:exithouse(playerid, params[]) {
    for(new i = 0; i < MAX_HOUSES; i++) {
        // Corrigido: Usando 'i' em vez de 'id'
        if(IsPlayerInRangeOfPoint(playerid, 3.0, House[i][hIntX], House[i][hIntY], House[i][hIntZ])) {
            SetPlayerInterior(playerid, 0);
            SetPlayerPos(playerid, House[i][hX], House[i][hY], House[i][hZ]);
            return 1;
        }
    }
    return 1;
}

