#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <dini>

// ================= PATH =================
stock ContaPath(playerid, path[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof nome);
    format(path, size, "Contas/%s.ini", nome);
}

// ================= CHECAR ADMIN =========
stock IsAdmin(playerid, level)
{
    new path[64];
    ContaPath(playerid, path, sizeof path);

    if(!dini_Exists(path)) return 0;
    return dini_Int(path, "Admin") >= level;
}

// ================= SET ADMIN =============
CMD:setadmin(playerid, params[])
{
    if(!IsPlayerAdmin(playerid))
        return SendClientMessage(playerid, -1, "Você não é RCON.");

    new id, lvl;
    if(sscanf(params, "dd", id, lvl))
        return SendClientMessage(playerid, -1, "/setadmin [id] [nivel]");

    if(!IsPlayerConnected(id))
        return SendClientMessage(playerid, -1, "Player inválido.");

    new path[64];
    ContaPath(id, path, sizeof path);

    dini_IntSet(path, "Admin", lvl);

    SendClientMessage(id, -1, "Você recebeu nível de admin.");
    SendClientMessage(playerid, -1, "Admin setado com sucesso.");
    return 1;
}

// ================= ADMIN TEST ===========
CMD:a(playerid)
{
    if(!IsAdmin(playerid, 1))
        return SendClientMessage(playerid, -1, "Você não é admin.");

    SendClientMessage(playerid, -1, "Comando admin funcionando.");
    return 1;
}

