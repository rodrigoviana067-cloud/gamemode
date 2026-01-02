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
    hOwner[MAX_PLAYER_NAME], // Mudamos para String para salvar o NOME do dono
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
    
    // Carrega o nome do dono
    format(House[id][hOwner], MAX_PLAYER_NAME, "%s", dini_Get(file, "Owner"));
    House[id][hLocked] = dini_Int(file, "Locked");

    // Limpar se já existir (evita duplicatas)
    if(House[id][hLabel] != Text3D:0) DestroyDynamic3DTextLabel(House[id][hLabel]);
    if(House[id][hPickup] != 0) DestroyDynamicPickup(House[id][hPickup]);

    new label[128];
    if(!strcmp(House[id][hOwner], "Ninguem", true)) 
    {
        format(label, sizeof label, "{00FF00}Casa à venda\n{FFFFFF}Preço: {00FF00}$%d\n{FFFFFF}/buyhouse", HOUSE_PRICE);
        House[id][hPickup] = CreateDynamicPickup(1273, 1, House[id][hX], House[id][hY], House[id][hZ]);
        House[id][hLabel] = CreateDynamic3DTextLabel(label, -1, House[id][hX], House[id][hY], House[id][hZ] + 0.8, 10.0);
    }
    else 
    {
        format(label, sizeof label, "{00CCFF}Casa de: {FFFFFF}%s\n{00CCFF}Status: %s\n{FFFFFF}/enterhouse", House[id][hOwner], (House[id][hLocked] ? "{FF0000}Trancada" : "{00FF00}Aberta"));
        House[id][hPickup] = CreateDynamicPickup(1272, 1, House[id][hX], House[id][hY], House[id][hZ]);
        House[id][hLabel] = CreateDynamic3DTextLabel(label, -1, House[id][hX], House[id][hY], House[id][hZ] + 0.8, 10.0);
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

// ... Restante dos comandos (/sethouse, /buyhouse, /lockhouse, /enterhouse)
