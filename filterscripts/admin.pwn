#include <a_samp>
#include <zcmd>
#include <dini>

// ================= CONFIG =================
#define COR_ADMIN 0xFF0000FF

new AdminLevel[MAX_PLAYERS];

// ================= PATH =================
stock ContaPath(playerid, path[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof nome);
    format(path, size, "Contas/%s.ini", nome);
}

// ================= INIT =================
public OnFilterScriptInit()
{
    print("[ADMIN] Sistema de admin carregado.");
    return 1;
}

// ================= CONNECT =================
public OnPlayerConnect(playerid)
{
    AdminLevel[playerid] = 0;
    return 1;
}

// ================= LOAD ADMIN =================
public OnPlayerSpawn(playerid)
{
    new path[64];
    ContaPath(playerid, path, sizeof path);

    if(dini_Exists(path))
    {
        AdminLevel[playerid] = dini_Int(path, "Admin");
    }
    return 1;
}

// ================= HELP =================
CMD:admins(playerid, params[])
{
    SendClientMessage(playerid, COR_ADMIN, "Admins online:");
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && AdminLevel[i] > 0)
        {
            new nome[MAX_PLAYER_NAME], msg[64];
            GetPlayerName(i, nome, sizeof nome);
            format(msg, sizeof msg, "%s - Nivel %d", nome, AdminLevel[i]);
            SendClientMessage(playerid, COR_ADMIN, msg);
        }
    }
    return 1;
}

// ================= SETADMIN =================
CMD:setadmin(playerid, params[])
{
    if(AdminLevel[playerid] < 5)
        return SendClientMessage(playerid, -1, "Você não é dono do servidor.");

    new id, nivel;
    if(sscanf(params, "dd", id, nivel))
        return SendClientMessage(playerid, -1, "/setadmin [id] [nivel]");

    if(!IsPlayerConnected(id))
        return SendClientMessage(playerid, -1, "Jogador offline.");

    if(nivel < 0 || nivel > 5)
        return SendClientMessage(playerid, -1, "Nivel inválido (0 a 5).");

    AdminLevel[id] = nivel;

    new path[64];
    ContaPath(id, path, sizeof path);
    dini_IntSet(path, "Admin", nivel);

    SendClientMessage(playerid, COR_ADMIN, "Admin setado com sucesso.");
    SendClientMessage(id, COR_ADMIN, "Seu nível de admin foi alterado.");
    return 1;
}

// ================= KICK =================
CMD:kick(playerid, params[])
{
    if(AdminLevel[playerid] < 2)
        return SendClientMessage(playerid, -1, "Admin nivel 2+.");

    new id, motivo[64];
    if(sscanf(params, "ds[64]", id, motivo))
        return SendClientMessage(playerid, -1, "/kick [id] [motivo]");

    Kick(id);
    return 1;
}

// ================= BAN =================
CMD:ban(playerid, params[])
{
    if(AdminLevel[playerid] < 3)
        return SendClientMessage(playerid, -1, "Admin nivel 3+.");

    new id;
    if(sscanf(params, "d", id))
        return SendClientMessage(playerid, -1, "/ban [id]");

    Ban(id);
    return 1;
}

// ================= GOTO =================
CMD:goto(playerid, params[])
{
    if(AdminLevel[playerid] < 2)
        return SendClientMessage(playerid, -1, "Admin nivel 2+.");

    new id;
    if(sscanf(params, "d", id))
        return SendClientMessage(playerid, -1, "/goto [id]");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(id, x, y, z);
    SetPlayerPos(playerid, x+1, y, z);
    return 1;
}

// ================= TRazer =================
CMD:trazer(playerid, params[])
{
    if(AdminLevel[playerid] < 2)
        return SendClientMessage(playerid, -1, "Admin nivel 2+.");

    new id;
    if(sscanf(params, "d", id))
        return SendClientMessage(playerid, -1, "/trazer [id]");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    SetPlayerPos(id, x+1, y, z);
    return 1;
}
