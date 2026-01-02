#include <a_samp>
#include <zcmd>

// IDs de Diálogos
#define DIALOG_GPS_FS 550
#define DIALOG_INFO   551

// ======================
// COMANDO AJUDA
// ======================
CMD:ajuda(playerid, params[])
{
    SendClientMessage(playerid, 0x00CCFFFF, "=== {FFFFFF}CENTRAL DE AJUDA 2026 {00CCFF}===");
    SendClientMessage(playerid, -1, "{00CCFF}/gps {FFFFFF}- Localizações principais da cidade");
    SendClientMessage(playerid, -1, "{00CCFF}/info {FFFFFF}- Ver suas informações e status");
    SendClientMessage(playerid, -1, "{00CCFF}/guia {FFFFFF}- Tutorial para novatos");
    SendClientMessage(playerid, -1, "{00CCFF}/ajuda {FFFFFF}- Lista de comandos");
    return 1;
}

// ======================
// COMANDO INFO (Substitui o /dinheiro)
// ======================
CMD:info(playerid, params[])
{
    new name[MAX_PLAYER_NAME], ip[16], msg[500];
    GetPlayerName(playerid, name, sizeof(name));
    GetPlayerIp(playerid, ip, sizeof(ip));

    format(msg, sizeof(msg), 
        "{00CCFF}Nome: {FFFFFF}%s\n\
        {00CCFF}Dinheiro em Mãos: {00FF00}$%d\n\
        {00CCFF}Score/Nível: {FFFFFF}%d\n\
        {00CCFF}Ping: {FFFFFF}%d\n\
        {00CCFF}Seu IP: {FFFFFF}%s\n\n\
        {FFFF00}Cidade Full 2026 - O Futuro é Agora!", 
        name, 
        GetPlayerMoney(playerid), 
        GetPlayerScore(playerid), 
        GetPlayerPing(playerid), 
        ip
    );

    ShowPlayerDialog(playerid, DIALOG_INFO, DIALOG_STYLE_MSGBOX, "{00CCFF}Suas Informações", msg, "Fechar", "");
    return 1;
}

// ======================
// COMANDO GPS COMPLETO
// ======================
CMD:gps(playerid, params[])
{
    new lista[300];
    strcat(lista, "Banco Central LS\n");
    strcat(lista, "Prefeitura (Empregos)\n");
    strcat(lista, "Hospital Central\n");
    strcat(lista, "Delegacia de Polícia\n");
    strcat(lista, "Concessionária de Veículos\n");
    strcat(lista, "Mina de Mineração\n");
    strcat(lista, "Aeroporto (Spawn)");

    ShowPlayerDialog(playerid, DIALOG_GPS_FS, DIALOG_STYLE_LIST, "{00CCFF}GPS - Cidade Full 2026", lista, "Marcar", "Sair");
    return 1;
}

// ======================
// RESPOSTAS DE DIÁLOGOS
// ======================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_GPS_FS && response)
    {
        new Float:X, Float:Y, Float:Z, local[32];
        switch(listitem)
        {
            case 0: { X = 1467.0; Y = -1010.0; Z = 26.0; local = "Banco Central"; }
            case 1: { X = 1481.0; Y = -1741.0; Z = 13.0; local = "Prefeitura"; }
            case 2: { X = 1172.3; Y = -1341.3; Z = 13.5; local = "Hospital"; }
            case 3: { X = 1543.0; Y = -1675.0; Z = 13.5; local = "Delegacia"; }
            case 4: { X = 1045.0; Y = -2036.0; Z = 15.5; local = "Concessionária"; }
            case 5: { X = 2933.0; Y = 2500.0; Z = 45.0; local = "Mina"; }
            case 6: { X = 1642.17; Y = -2256.39; Z = 13.49; local = "Aeroporto"; }
        }
        SetPlayerCheckpoint(playerid, X, Y, Z, 4.0);
        new msg[100];
        format(msg, sizeof(msg), "{00FF00}[GPS] {FFFFFF}Localização de '%s' marcada no seu mapa!", local);
        SendClientMessage(playerid, -1, msg);
        return 1;
    }
    return 0;
}

public OnPlayerEnterCheckpoint(playerid)
{
    DisablePlayerCheckpoint(playerid);
    SendClientMessage(playerid, 0xFFFF00FF, "[GPS] Você chegou ao seu destino!");
    PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
    return 1;
}
