#include <a_samp>
#include <zcmd>
#include <dini>

#define COR_ADMIN 0xFF0000FF

new AdminLevel[MAX_PLAYERS];

// ================= PATH =================
stock ContaPath(playerid, path[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof nome);
    format(path, size, "Contas/%s.ini", nome);
}

// ================= STRTOK =================
stock strtok(const string[], &index)
{
    new length = strlen(string);
    while ((index < length) && (string[index] <= ' '))
        index++;

    new offset = index;
    new result[20];
    while ((index < length) && (string[index] > ' '))
    {
        result[index - offset] = string[index];
        index++;
    }
    result[index - offset] = EOS;
    return result;
}

// ================= INIT =================
public OnFilterScriptInit()
{
    print("[ADMIN] Sistema de admin carregado.");
    return 1;
}

public OnPlayerSpawn(playerid)
{
    new path[64];
    ContaPath(playerid, path, sizeof path);

    if(dini_Exists(path))
        AdminLevel[playerid] = dini_Int(path, "Admin");

    return 1;
}

// ================= SETADMIN =================
CMD:setadmin(playerid, params[])
{
    if(AdminLevel[playerid] < 5)
        return SendClientMessage(playerid, -1, "Você não é dono.");

    new idx, id, nivel;
    id = strval(strtok(params, idx));
    nivel = strval(strtok(params, idx));

    if(!IsPlayerConnected(id))
        return SendClientMessage(playerid, -1, "/setadmin [id] [nivel]");

    AdminLevel[id] = nivel;

    new path[64];
    ContaPath(id, path, sizeof path);
    dini_IntSet(path, "Admin", nivel);

    SendClientMessage(playerid, COR_ADMIN, "Admin definido.");
    return 1;
}

// ================= KICK =================
CMD:kick(playerid, params[])
{
    if(AdminLevel[playerid] < 2)
        return SendClientMessage(playerid, -1, "Admin 2+.");

    new idx, id;
    id = strval(strtok(params, idx));

    if(!IsPlayerConnected(id))
        return SendClientMessage(playerid, -1, "/kick [id]");

    Kick(id);
    return 1;
}

// ================= BAN =================
CMD:ban(playerid, params[])
{
    if(AdminLevel[playerid] < 3)
        return SendClientMessage(playerid, -1, "Admin 3+.");

    new id = strval(params);
    if(!IsPlayerConnected(id))
        return SendClientMessage(playerid, -1, "/ban [id]");

    Ban(id);
    return 1;
}

// ================= GOTO =================
CMD:goto(playerid, params[])
{
    if(AdminLevel[playerid] < 2)
        return SendClientMessage(playerid, -1, "Admin 2+.");

    new id = strval(params);
    new Float:x, Float:y, Float:z;

    GetPlayerPos(id, x, y, z);
    SetPlayerPos(playerid, x+1, y, z);
    return 1;
}

// ================= TRazer =================
CMD:trazer(playerid, params[])
{
    if(AdminLevel[playerid] < 2)
        return SendClientMessage(playerid, -1, "Admin 2+.");

    new id = strval(params);
    new Float:x, Float:y, Float:z;

    GetPlayerPos(playerid, x, y, z);
    SetPlayerPos(id, x+1, y, z);
    return 1;
}
