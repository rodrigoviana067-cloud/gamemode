#include <a_samp>
#include <zcmd>
#include <sscanf2>

// =====================
// DEFINES
// =====================
#define COR_BRANCO   0xFFFFFFFF
#define COR_VERMELHO 0xFF0000FF
#define COR_VERDE    0x00FF00FF
#define COR_AMARELO  0xFFFF00FF

#define DIALOG_LOGIN     1
#define DIALOG_REGISTRO  2

#define USER_PATH "scriptfiles/contas/%s.ini"

// =====================
// VARIÁVEIS
// =====================
new bool:Logado[MAX_PLAYERS];
new PlayerAdminLevel[MAX_PLAYERS];

// =====================
// FUNÇÕES DE ARQUIVO
// =====================
stock GetUserFile(playerid, dest[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(dest, size, USER_PATH, nome);
}

stock RegistrarConta(playerid, const senha[])
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

stock bool:ChecarSenha(playerid, const senha[])
{
    new File:f;
    new file[64], linha[128];
    new prefix[7];
    GetUserFile(playerid, file, sizeof(file));

    f = fopen(file, io_read);
    if (!f) return false;

    while (fread(f, linha))
    {
        strmid(prefix, linha, 0, 6); // "Senha=" tem 6 chars
        if (!strcmp(prefix, "Senha=", false))
        {
            new saved[64];
            strmid(saved, linha, 6, strlen(linha) - 1);
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
    new prefix[7];
    GetUserFile(playerid, file, sizeof(file));

    f = fopen(file, io_read);
    if (!f) return;

    while (fread(f, linha))
    {
        strmid(prefix, linha, 0, 6); // "Admin="
        if (!strcmp(prefix, "Admin=", false))
        {
            PlayerAdminLevel[playerid] = strval(linha[6]);
            break;
        }
    }
    fclose(f);
}

stock GetSenhaSalva(playerid, senha[], size)
{
    new File:f;
    new file[64], linha[128];
    new prefix[7];
    GetUserFile(playerid, file, sizeof(file));

    f = fopen(file, io_read);
    if (!f) return 0;

    while (fread(f, linha))
    {
        strmid(prefix, linha, 0, 6);
        if (!strcmp(prefix, "Senha=", false))
        {
            strmid(senha, linha, 6, strlen(linha) - 1);
            fclose(f);
            return 1;
        }
    }
    fclose(f);
    return 0;
}

stock SalvarAdmin(playerid)
{
    new File:f;
    new file[64], senha[64];
    GetUserFile(playerid, file, sizeof(file));

    if (!GetSenhaSalva(playerid, senha, sizeof(senha)))
        return;

    f = fopen(file, io_write);
    if (!f) return;

    new str[128];
    format(str, sizeof(str), "Senha=%s\nAdmin=%d\n", senha, PlayerAdminLevel[playerid]);
    fwrite(f, str);
    fclose(f);
}

// =====================
// FILTERSCRIPT INIT
// =====================
public OnFilterScriptInit()
{
    print("[CMD] Sistema de Login/Admin carregado com sucesso");
    return 1;
}

// =====================
// PLAYER CONNECT
// =====================
public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    PlayerAdminLevel[playerid] = 0;

    new file[64];
    GetUserFile(playerid, file, sizeof(file));

    if (fexist(file))
    {
        ShowPlayerDialog(
            playerid,
            DIALOG_LOGIN,
            DIALOG_STYLE_PASSWORD,
            "Login",
            "Digite sua senha:",
            "Entrar",
            "Sair"
        );
    }
    else
    {
        ShowPlayerDialog(
            playerid,
            DIALOG_REGISTRO,
            DIALOG_STYLE_PASSWORD,
            "Registro",
            "Crie uma senha:",
            "Registrar",
            "Sair"
        );
    }
    return 1;
}

// =====================
// DIALOG RESPONSE
// =====================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (!response) return Kick(playerid);

    if (dialogid == DIALOG_REGISTRO)
    {
        if (strlen(inputtext) < 3)
        {
            ShowPlayerDialog(
                playerid,
                DIALOG_REGISTRO,
                DIALOG_STYLE_PASSWORD,
                "Registro",
                "Senha muito curta (mínimo 3 caracteres).",
                "Registrar",
                "Sair"
            );
            return 1;
        }

        RegistrarConta(playerid, inputtext);
        Logado[playerid] = true;

        SendClientMessage(playerid, COR_VERDE, "Conta registrada com sucesso!");
        return 1;
    }

    if (dialogid == DIALOG_LOGIN)
    {
        if (!ChecarSenha(playerid, inputtext))
        {
            SendClientMessage(playerid, COR_VERMELHO, "Senha incorreta.");
            return Kick(playerid);
        }

        Logado[playerid] = true;
        CarregarAdmin(playerid);

        SendClientMessage(playerid, COR_VERDE, "Login efetuado com sucesso!");
        return 1;
    }
    return 0;
}

// =====================
// COMANDO ADMIN
// =====================
CMD:setadmin(playerid, params[])
{
    if (PlayerAdminLevel[playerid] < 5)
        return SendClientMessage(playerid, COR_VERMELHO, "Você não tem permissão.");

    new id, nivel;
    if (sscanf(params, "ii", id, nivel))
        return SendClientMessage(playerid, COR_AMARELO, "Uso: /setadmin [id] [nivel]");

    if (!IsPlayerConnected(id))
        return SendClientMessage(playerid, COR_VERMELHO, "Jogador não conectado.");

    PlayerAdminLevel[id] = nivel;
    SalvarAdmin(id);

    SendClientMessage(id, COR_VERDE, "Você recebeu admin!");
    SendClientMessage(playerid, COR_VERDE, "Admin definido com sucesso.");
    return 1;
}
