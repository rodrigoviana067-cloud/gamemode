#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <dini>

#define MAX_HOUSES 500
// Pega o nível de admin do outro script
extern AdminLevel[MAX_PLAYERS]; 

enum hInfo {
    Float:hX, Float:hY, Float:hZ,
    Float:hIntX, Float:hIntY, Float:hIntZ,
    hInterior, hPreco, hOwner[MAX_PLAYER_NAME], hLocked,
    Text3D:hLabel, hPickup
};
new House[MAX_HOUSES][hInfo];

stock HouseFile(id, string[], size) { format(string, size, "houses/house_%d.ini", id); }

public OnFilterScriptInit() {
    for(new i = 0; i < MAX_HOUSES; i++) LoadHouse(i);
    return 1;
}

// COMANDO ADMIN PARA CRIAR CASA (Agora funcional)
CMD:sethouse(playerid, params[]) {
    // Verifica se é Admin Master OU Admin RCON
    if(AdminLevel[playerid] < 5 && !IsPlayerAdmin(playerid)) 
        return SendClientMessage(playerid, -1, "{FF0000}Erro: Comando exclusivo para Admins Nível 5+ ou RCON.");

    new id, valor;
    if(sscanf(params, "ii", id, valor)) return SendClientMessage(playerid, -1, "{00CCFF}Uso: /sethouse [ID] [PREÇO]");

    GetPlayerPos(playerid, House[id][hX], House[id][hY], House[id][hZ]);
    House[id][hIntX] = House[id][hX]; House[id][hIntY] = House[id][hY]; House[id][hIntZ] = House[id][hZ];
    House[id][hInterior] = GetPlayerInterior(playerid);
    House[id][hPreco] = valor;
    format(House[id][hOwner], MAX_PLAYER_NAME, "Ninguem");
    House[id][hLocked] = 0;

    SaveHouse(id); LoadHouse(id);
    SendClientMessage(playerid, 0x00CCFFFF, "[CASA] Criada com sucesso! Use /sethpoint para o interior.");
    return 1;
}

// Carregar/Salvar (Mantenha as funções LoadHouse e SaveHouse que enviamos antes)
// ... (Adicione os comandos /buyhouse, /enterhouse, /lockhouse)
