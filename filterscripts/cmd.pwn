#include <a_samp>
#include <zcmd>
#include "sscanf2.inc"

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
new PlayerAdminLevel[MAX_PLAYERS];
#define ADMIN_FILE "admins.txt"

// ======================
// FILTERSCRIPT INIT / EXIT
// ======================
public OnFilterScriptInit()
{
    print("[CMD] Filterscript CMD + RP carregado");
    LoadAdmins(); // Carrega admins do arquivo
    return 1;
}

public OnFilterScriptExit()
{
    print("[CMD] Filterscript CMD + RP descarregado");
    SaveAdmin(); // Salva admins ao desligar
    return 1;
}

// ======================
// PLAYER CONNECT
// ======================
public OnPlayerConnect(playerid)
{
    PlayerAdminLevel[playerid] = 0;
    SendClientMessage(playerid, COR_VERDE, "Bem-vindo ao servidor RP!");
    return 1;
}

// ======================
// FUNÇÕES ADMIN
// ======================
stock bool:IsAdmin(playerid, level)
{
    return PlayerAdminLevel[playerid] >= level;
}

// ======================
// FUNÇÕES DE SAVE/LOAD
// ======================
stock SaveAdmin()
{
    new file = fopen(ADMIN_FILE, io_write_text);
    if (file)
    {
        for (new i = 0; i < MAX_PLAYERS; i++)
        {
            if (PlayerAdminLevel[i] > 0)
            {
                new name[MAX_PLAYER_NAME];
                GetPlayerName(i, name, sizeof(name));
                fprintf(file, "%s %d\n", name, PlayerAdminLevel[i]);
            }
        }
        fclose(file);
    }
}

stock LoadAdmins()
{
    new file = fopen(ADMIN_FILE, io_read_text);
    if (!file) return;

    new line[64];
    while (!feof(file))
    {
        if (fgets(file, line, sizeof(line)))
        {
            new name[MAX_PLAYER_NAME];
            new level;
            if (sscanf(line, "s[i] i", name, sizeof(name), level) == 2)
            {
                // procura jogador online com esse nome
                for (new i = 0; i < MAX_PLAYERS; i++)
                {
                    new pname[MAX_PLAYER_NAME];
                    GetPlayerName(i, pname, sizeof(pname));
                    if (strcmp(name, pname, true) == 0)
                        PlayerAdminLevel[i] = level;
                }
            }
        }
    }
    fclose(file);
}

// ======================
// COMANDOS RP
// ======================
CMD:me(playerid, params[])
{
    if (isnull(params))
        return SendClientMessage(playerid, COR_VERMELHO, "Uso: /me [ação]");

    new msg[144], nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(msg, sizeof(msg), "* %s %s", nome, params);
    SendClientMessageToAll(COR_ROXO, msg);
    return 1;
}

CMD:do(playerid, params[])
{
    if (isnull(params))
        return SendClientMessage(playerid, COR_VERMELHO, "Uso: /do [descrição]");

    new msg[144];
    format(msg, sizeof(msg), "* %s (( %d ))", params, playerid);
    SendClientMessageToAll(COR_CINZA, msg);
    return 1;
}

CMD:ame(playerid, params[])
{
    if (isnull(params))
        return SendClientMessage(playerid, COR_VERMELHO, "Uso: /ame [ação próxima]");

    new msg[144], nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(msg, sizeof(msg), "* %s %s", nome, params);
    SendClientMessageToAll(COR_AMARELO, msg);
    return 1;
}

// ======================
// COMANDOS PLAYER
// ======================
CMD:ajuda(playerid)
{
    SendClientMessage(playerid, COR_AMARELO, "=== Comandos RP ===");
    SendClientMessage(playerid, COR_BRANCO, "/me /do /ame /pm /hora /id");
    return 1;
}

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
    format(str, sizeof(str), "Seu ID é: %d", playerid);
    SendClientMessage(playerid, COR_VERDE, str);
    return 1;
}

CMD:pm(playerid, params[])
{
    new id, msg[128];
    if (sscanf(params, "is[128]", id, msg))
        return SendClientMessage(playerid, COR_VERMELHO, "Uso: /pm [id] [mensagem]");

    if (!IsPlayerConnected(id))
        return SendClientMessage(playerid, COR_VERMELHO, "Jogador não conectado.");

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
        return SendClientMessage(playerid, COR_VERMELHO, "Você não é administrador nível 5.");

    new id, level;
    if (sscanf(params, "ii", id, level))
        return SendClientMessage(playerid, COR_VERMELHO, "Uso: /setadmin [id] [nivel]");

    PlayerAdminLevel[id] = level;
    SaveAdmin(); // salva imediatamente

    new str[96];
    format(str, sizeof(str), "Admin %d setou admin nível %d para %d", playerid, level, id);
    SendClientMessageToAll(COR_VERMELHO, str);
    return 1;
}

CMD:kick(playerid, params[])
{
    if (!IsAdmin(playerid, 1))
        return SendClientMessage(playerid, COR_VERMELHO, "Você não é administrador.");

    new id, motivo[64];
    if (sscanf(params, "is[64]", id, motivo))
        return SendClientMessage(playerid, COR_VERMELHO, "Uso: /kick [id] [motivo]");

    new str[128];
    format(str, sizeof(str), "Admin %d kickou %d. Motivo: %s", playerid, id, motivo);
    SendClientMessageToAll(COR_VERMELHO, str);
    Kick(id);
    return 1;
}

CMD:ir(playerid, params[])
{
    if (!IsAdmin(playerid, 1))
        return SendClientMessage(playerid, COR_VERMELHO, "Você não é administrador.");

    new id;
    if (sscanf(params, "i", id))
        return SendClientMessage(playerid, COR_VERMELHO, "Uso: /ir [id]");

    new Float:x, y, z;
    GetPlayerPos(id, x, y, z);
    SetPlayerPos(playerid, x + 1.0, y, z);
    return 1;
}

CMD:trazer(playerid, params[])
{
    if (!IsAdmin(playerid, 1))
        return SendClientMessage(playerid, COR_VERMELHO, "Você não é administrador.");

    new id;
    if (sscanf(params, "i", id))
        return SendClientMessage(playerid, COR_VERMELHO, "Uso: /trazer [id]");

    new Float:x, y, z;
    GetPlayerPos(playerid, x, y, z);
    SetPlayerPos(id, x + 1.0, y, z);
    return 1;
}
