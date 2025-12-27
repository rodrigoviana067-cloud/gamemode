#include <a_samp>
#include <zcmd>

// ================= DINHEIRO =================
CMD:dinheiro(playerid)
{
    new msg[64];
    format(msg, sizeof msg, "Seu dinheiro: $%d", GetPlayerMoney(playerid));
    SendClientMessage(playerid, -1, msg);
    return 1;
}

// ================= STATS ====================
CMD:stats(playerid)
{
    SendClientMessage(playerid, -1, "Cidade RP Full - Sistema ativo.");
    return 1;
}
