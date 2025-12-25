#include <a_samp>
#include <zcmd>
#include <sscanf2>

// ======================
// CORES
// ======================
#define COR_BRANCO   0xFFFFFFFF
#define COR_VERMELHO 0xFF0000FF
#define COR_VERDE    0x00FF00FF
#define COR_AMARELO  0xFFFF00FF
#define COR_CINZA    0xAAAAAAFF
#define COR_ROXO     0xC2A2DAFF

// ======================
// VARIÁVEIS
// ======================
#define ADMIN_FILE "admins.txt"
new PlayerAdminLevel[MAX_PLAYERS];

// ======================
// INIT / EXIT
// ======================
public OnFilterScriptInit()
{
    print("[CMD] Filterscript CMD carregado");
    LoadAdmins();
    return 1;
}

public OnFilterScriptExit()
{
    SaveAdmins();
    return 1;
}

public OnPlayerConnect(playerid)
{
    PlayerAdminLevel[playerid] = 0;
    LoadAdminForPlayer(playerid);
    SendClientMessage(playerid, COR_VERDE, "Bem-vindo ao servidor RP!");
    return 1;
}

// ======================
// ADMIN
// ======================
stock bool:IsAdmin(playerid, level)
{
    return PlayerAdminLevel[playerid] >= level;
}

// ======================
// SAVE / LOAD
// ======================
stock SaveAdmins()
{
    new File:f = fopen(ADMIN_FILE, io_write);
    if (!f) return;

    new name[MAX_PLAYER_NAME], line[64];
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (PlayerAdminLevel[i] > 0 && IsPlayerConnected(i))
        {
            GetPlayerName(i, name, sizeof(name));
            format(line, sizeof(line), "%s %d\r\n", name, PlayerAdminLevel[i]);
            fwrite(f, line);
        }
    }
    fclose(f);
}

stock LoadAdmins()
{
    if (!fexist(ADMIN_FILE)) return;

    new File:f = fopen(ADMIN_FILE, io_read);
    if (!f) return;

    new line[64];
    while (fread(f, line))
    {
        new name[MAX_PLAYER_NAME], level;
        if (sscanf(line, "s[24] i", name, level) == 0)
        {
            for (new i = 0; i < MAX_PLAYERS; i++)
            {
                if (IsPlayerConnected(i))
                {
                    new pname[MAX_PLAYER_NAME];
                    GetPlayerName(i, pname, sizeof(pname));
                    if (!strcmp(pname, name, true))
                        PlayerAdminLevel[i] = level;
                }
            }
        }
    }
    fclose(f);
}

stock LoadAdminForPlayer(playerid)
{
    if (!fexist(ADMIN_FILE)) return;

    new File:f = fopen(ADMIN_FILE, io_read);
    if (!f) return;

    new line[64], name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));

    while (fread(f, line))
    {
        new pname[MAX_PLAYER_NAME], level;
        if (sscanf(line, "s[24] i", pname, level) == 0)
        {
            if (!strcmp(pname, name, true))
            {
                PlayerAdminLevel[playerid] = level;
                break;
            }
        }
    }
    fclose(f);
}

// ======================
// COMANDOS PLAYER
// ======================
CMD:hora(playerid)
{
    new h, m, s, str[64];
    gettime(h, m, s);
    format(str, sizeof(str), "Hora do servidor: %02d:%02d:%02d", h, m, s);
    SendClientMessage(playerid, COR_VERDE, str);
    return 1;
}

CMD:id(playerid)
{
    new str[64];
    format(str, sizeof(str), "Seu ID é %d", playerid);
    SendClientMessage(playerid, COR_VERDE, str);
    return 1;
}

CMD:pm(playerid, params[])
{
    new id, msg[128];
    if (sscanf(params, "is[128]", id, msg))
        return SendClientMessage(playerid, COR_VERMELHO, "Uso: /pm [id] [msg]");

    new str[160];
    format(str, sizeof(str), "[PM] %d -> %d: %s", playerid, id, msg);
    SendClientMessage(playerid, COR_AMARELO, str);
    SendClientMessage(id, COR_AMARELO, str);
    return 1;
}

// ======================
// COMANDOS ADMIN
// ======================
CMD:setadmin(playerid, params[])
{
    if (!IsAdmin(playerid, 5))
        return SendClientMessage(playerid, COR_VERMELHO, "Você não é admin 5.");

    new id, level;
    if (sscanf(params, "ii", id, level))
        return SendClientMessage(playerid, COR_VERMELHO, "Uso: /setadmin [id] [nivel]");

    PlayerAdminLevel[id] = level;
    SaveAdmins();

    new str[96];
    format(str, sizeof(str), "Admin %d setou admin %d para %d", playerid, level, id);
    SendClientMessageToAll(COR_VERMELHO, str);
    return 1;
}

CMD:kick(playerid, params[])
{
    if (!IsAdmin(playerid, 1))
        return SendClientMessage(playerid, COR_VERMELHO, "Sem permissão.");

    new id, motivo[64];
    if (sscanf(params, "is[64]", id, motivo))
        return SendClientMessage(playerid, COR_VERMELHO, "Uso: /kick [id] [motivo]");

    Kick(id);
    return 1;
}
