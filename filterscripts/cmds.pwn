#include <a_samp>
#include <zcmd>

// ======================
// COMANDO DINHEIRO
// ======================
CMD:dinheiro(playerid)
{
    new msg[64];
    format(msg, sizeof msg, "Seu dinheiro: $%d", GetPlayerMoney(playerid));
    SendClientMessage(playerid, -1, msg);
    return 1;
}

// ======================
// COMANDO AJUDA
// ======================
CMD:ajuda(playerid)
{
    SendClientMessage(playerid, -1, "Comandos: /dinheiro /ajuda");
    return 1;
}
