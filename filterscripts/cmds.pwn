#include <a_samp>
#include <zcmd>

extern bool:Logado[MAX_PLAYERS];

CMD:dinheiro(playerid)
{
    if(!Logado[playerid]) return SendClientMessage(playerid, -1, "Logue primeiro.");
    new s[64];
    format(s, sizeof s, "Seu dinheiro: $%d", GetPlayerMoney(playerid));
    SendClientMessage(playerid, -1, s);
    return 1;
}

CMD:stats(playerid)
{
    if(!Logado[playerid]) return SendClientMessage(playerid, -1, "Logue primeiro.");
    SendClientMessage(playerid, -1, "Sistema RP Full ativo.");
    return 1;
}
