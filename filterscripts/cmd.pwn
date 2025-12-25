#include <a_samp>
#include <zcmd>
#include <sscanf2>

// CORES
#define COR_VERDE 0x00FF00FF
#define COR_VERMELHO 0xFF0000FF

#define DIALOG_LOGIN 1
#define DIALOG_REGISTRO 2

#define USER_PATH "scriptfiles/contas/%s.ini"

// VARIÁVEIS
new bool:Logado[MAX_PLAYERS];
new PlayerAdminLevel[MAX_PLAYERS];

// ===================
// HELPERS
// ===================
stock GetUserFile(playerid, dest[], size)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(dest, size, USER_PATH, name);
}

stock RegistrarConta(playerid, senha[])
{
    new File:f;
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    f = fopen(file, io_write);
    if (!f) return 0;

    fwrite(f, "Senha=");
    fwrite(f, senha);
    fwrite(f, "\nAdmin=0\n");
    fclose(f);
    return 1;
}

stock bool:ChecarSenha(playerid, senha[])
{
    new File:f;
    new file[64], linha[128];
    GetUserFile(playerid, file, sizeof(file));

    f = fopen(file, io_read);
    if (!f) return false;

    while (!feof(f))
    {
        fread(f, linha);
        if (strfind(linha, "Senha=", true) != -1)
        {
            new saved[64];
            strmid(saved, linha, 6, strlen(linha)-1);
            fclose(f);
            return !strcmp(saved, senha, false);
        }
    }
    fclose(f);
    return false;
}

stock CarregarAdmin(playerid)
{
    new File:f;
    new file[64], linha[64];
    GetUserFile(playerid, file, sizeof(file));

    f = fopen(file, io_read);
    if (!f) return;

    while (!feof(f))
    {
        fread(f, linha);
        if (strfind(linha, "Admin=", true) != -1)
        {
            PlayerAdminLevel[playerid] = strval(linha[6]);
            break;
        }
    }
    fclose(f);
}

stock SalvarAdmin(playerid)
{
    new File:f;
    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    f = fopen(file, io_write);
    if (!f) return;

    new str[64];
    format(str, sizeof(str), "Senha=\nAdmin=%d\n", PlayerAdminLevel[playerid]);
    fwrite(f, str);
    fclose(f);
}

// ===================
// FILTERSCRIPT INIT
// ===================
public OnFilterScriptInit()
{
    print("[CMD] Sistema de Login/Admin carregado");
    return 1;
}

// ===================
// PLAYER CONNECT
// ===================
public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    PlayerAdminLevel[playerid] = 0;

    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    if (fexist(file))
    {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
            "Login", "Digite sua senha:", "Entrar", "Sair");
    }
    else
    {
        ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD,
            "Registro", "Crie uma senha:", "Registrar", "Sair");
    }
    return 1;
}

// ===================
// DIALOG RESPONSE
// ===================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (!response) return Kick(playerid);

    if (dialogid == DIALOG_REGISTRO)
    {
        if (strlen(inputtext) < 3)
            return ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD,
                "Registro", "Senha muito curta!", "Registrar", "Sair");

        RegistrarConta(playerid, inputtext);
        Logado[playerid] = true;
        SendClientMessage(playerid, COR_VERDE, "Conta registrada com sucesso!");
        return 1;
    }

    if (dialogid == DIALOG_LOGIN)
    {
        if (!ChecarSenha(playerid, inputtext))
            return Kick(playerid);

        Logado[playerid] = true;
        CarregarAdmin(playerid);
        SendClientMessage(playerid, COR_VERDE, "Login efetuado!");
        return 1;
    }
    return 0;
}

// ===================
// COMANDOS ADMIN
// ===================
CMD:setadmin(playerid, params[])
{
    if (PlayerAdminLevel[playerid] < 5)
        return SendClientMessage(playerid, COR_VERMELHO, "Sem permissão.");

    new id, nivel;
    if (sscanf(params, "ii", id, nivel)) return 1;

    PlayerAdminLevel[id] = nivel;
    SalvarAdmin(id);

    SendClientMessage(id, COR_VERDE, "Você recebeu admin!");
    SendClientMessage(playerid, COR_VERDE, "Admin setado com sucesso.");
    return 1;
}
