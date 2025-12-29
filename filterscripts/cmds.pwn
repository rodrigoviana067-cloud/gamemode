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
    SendClientMessage(playerid, -1, "=== COMANDOS DISPONÍVEIS ===");
    SendClientMessage(playerid, -1, "/menu - Menu principal");
    SendClientMessage(playerid, -1, "/gps - Localizações da cidade");
    SendClientMessage(playerid, -1, "/prefeitura - Empregos");
    SendClientMessage(playerid, -1, "/dinheiro - Ver seu dinheiro");
    return 1;
}

