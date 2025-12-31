#include <a_samp>
#include <zcmd>
#include <dini>

#include "cfg_constants.inc"
#include "player_data.inc"
#include "menus.inc"
#include "commands.inc"

// =================================================
// FUNÇÕES AUXILIARES
// =================================================

// Define o caminho do arquivo do jogador
stock ContaPath(playerid, buffer[], len)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(buffer, len, "contas/%s.ini", name);
}

// =================================================
// MAIN
// =================================================
main()
{
    print("---------------------------------------");
    print(" Cidade RP Full carregada com sucesso  ");
    print("---------------------------------------");
}

// =================================================
// GAMEMODE INIT
// =================================================
public OnGameModeInit()
{
    SetGameModeText("Cidade RP Full");
    // Criar arquivo de spawn padrão se não existir
    if(!dini_Exists("spawn.ini"))
    {
        dini_Create("spawn.ini");
        dini_FloatSet("spawn.ini", "X", -1257.5);
        dini_FloatSet("spawn.ini", "Y", -2704.9);
        dini_FloatSet("spawn.ini", "Z", 56.7);
        dini_FloatSet("spawn.ini", "A", 0.0);
    }
    return 1;
}

// =================================================
// PLAYER CONNECT & DISCONNECT
// =================================================
public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    PlayerEmprego[playerid] = EMPREGO_NENHUM;

    TogglePlayerControllable(playerid, false);

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    if (dini_Exists(path))
    {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
            "{FFFFFF}Login",
            "{FFFFFF}Bem-vindo de volta!\n{FFFFFF}Digite sua senha abaixo para entrar:",
            "Entrar", "Sair");
    }
    else
    {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
            "{FFFFFF}Registro",
            "{FFFFFF}Esta conta nao existe.\n{FFFFFF}Crie uma senha para se registrar:",
            "Registrar", "Sair");
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(Logado[playerid])
    {
        new path[64];
        ContaPath(playerid, path, sizeof(path));
        
        // Salva os dados antes de sair
        dini_IntSet(path, "Emprego", PlayerEmprego[playerid]);
        dini_IntSet(path, "Skin", GetPlayerSkin(playerid));
        
        // Opcional: Salvar posição atual para voltar onde parou
        /*
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        dini_FloatSet(path, "PosX", x);
        ... etc
        */
    }
    Logado[playerid] = false;
    return 1;
}

// =================================================
// DIALOG RESPONSE
// =================================================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    // Primeiro tenta processar dialogs externos (menus.inc/commands.inc)
    if (HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext))
        return 1;

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    if (dialogid == DIALOG_LOGIN)
    {
        if (!response) return Kick(playerid);

        new senha[32];
        format(senha, sizeof(senha), "%s", dini_Get(path, "Senha"));

        if (strcmp(inputtext, senha, false) == 0)
        {
            Logado[playerid] = true;
            PlayerEmprego[playerid] = dini_Int(path, "Emprego");
            
            TogglePlayerControllable(playerid, true);
            SpawnPlayer(playerid);
            SendClientMessage(playerid, 0x00FF00FF, "✅ Login realizado com sucesso!");
        }
        else
        {
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
                "Login", "{FF0000}Senha incorreta! {FFFFFF}Tente novamente:", "Entrar", "Sair");
        }
        return 1;
    }

    if (dialogid == DIALOG_REGISTER)
    {
        if (!response) return Kick(playerid);

        if (strlen(inputtext) < 3)
        {
            ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
                "Registro", "{FF0000}Senha muito curta! {FFFFFF}Tire ao menos 3 caracteres:", "Registrar", "Sair");
            return 1;
        }

        dini_Create(path);
        dini_Set(path, "Senha", inputtext);
        dini_IntSet(path, "Emprego", EMPREGO_NENHUM);
        dini_IntSet(path, "Skin", 60);

        Logado[playerid] = true;
        PlayerEmprego[playerid] = EMPREGO_NENHUM;

        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);
        SendClientMessage(playerid, 0x00FF00FF, "✅ Conta criada e logada com sucesso!");
        return 1;
    }
    return 0;
}

// =================================================
// PLAYER SPAWN
// =================================================
public OnPlayerSpawn(playerid)
{
    // Proteção: Não deixa spawnar sem logar
    if (!Logado[playerid])
    {
        Kick(playerid);
        return 0;
    }

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    // Carregar posição de Spawn do servidor
    if (dini_Exists("spawn.ini"))
    {
        SetPlayerPos(playerid, dini_Float("spawn.ini", "X"), dini_Float("spawn.ini", "Y"), dini_Float("spawn.ini", "Z"));
        SetPlayerFacingAngle(playerid, dini_Float("spawn.ini", "A"));
    }
    else
    {
        SetPlayerPos(playerid, -1257.5, -2704.9, 56.7);
        SetPlayerFacingAngle(playerid, 0.0);
    }

    // Aplicar Skin salva
    SetPlayerSkin(playerid, dini_Int(path, "Skin"));
    
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    return 1;
}
