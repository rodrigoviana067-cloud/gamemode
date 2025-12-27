#include <a_samp>
#include <zcmd>
#include <dini>

extern bool:Logado[MAX_PLAYERS];

stock ContaPath(playerid, path[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof nome);
    format(path, size, "Contas/%s.ini", nome);
}

CMD:setadmin(playerid, params[])
{
    new id, lvl;
    if(sscanf(params, "dd", id, lvl)) return SendClientMessage(playerid, -1, "/setadmin id nivel");

    new path[64];
    ContaPath(id, path, sizeof path);
    dini_IntSet(path, "Admin", lvl);

    SendClientMessage(id, -1, "Você virou admin.");
    return 1;
}
