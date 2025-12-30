// ================= CONNECT =================
public OnPlayerConnect(playerid)
{
    Logado[playerid] = false;
    PlayerEmprego[playerid] = EMPREGO_NENHUM;
    TogglePlayerControllable(playerid, false);

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    if(dini_Exists(path))
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
            "Login", "Digite sua senha:", "Entrar", "Sair");
    else
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
            "Registro", "Crie sua senha:", "Registrar", "Sair");

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(!Logado[playerid]) return 1;

    new path[64];
    ContaPath(playerid, path, sizeof(path));
    dini_IntSet(path, "Emprego", PlayerEmprego[playerid]);
    return 1;
}

// ================= SPAWN =================
public OnPlayerSpawn(playerid)
{
    SetPlayerSkin(playerid, SPAWN_SKIN);
    SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    return 1;
}

// ================= DIALOG RESPONSE =================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(!response) return 1;

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    // LOGIN
    if(dialogid == DIALOG_LOGIN)
    {
        new senha[32];
        dini_Get(path, "Senha", senha);

        if(strcmp(inputtext, senha, false) != 0)
        {
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
                "Login", "Senha incorreta:", "Entrar", "Sair");
            return 1;
        }

        Logado[playerid] = true;
        PlayerEmprego[playerid] = dini_Int(path, "Emprego");

        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);
        return 1;
    }

    // REGISTRO
    if(dialogid == DIALOG_REGISTER)
    {
        dini_Create(path);
        dini_Set(path, "Senha", inputtext);
        dini_IntSet(path, "Emprego", EMPREGO_NENHUM);

        Logado[playerid] = true;
        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);
        return 1;
    }

    // MENU
    if(dialogid == DIALOG_MENU)
    {
        if(listitem == 0) AbrirPrefeitura(playerid);
        if(listitem == 1) AbrirGPS(playerid);
        return 1;
    }

    // PREFEITURA
    if(dialogid == DIALOG_PREFEITURA)
    {
        if(listitem == 0)
        {
            ShowPlayerDialog(playerid, DIALOG_EMPREGOS, DIALOG_STYLE_LIST,
                "Empregos",
                "Polícia\nSAMU\nTaxi\nMecânico",
                "Selecionar", "Voltar");
        }
        else if(listitem == 1)
        {
            PlayerEmprego[playerid] = EMPREGO_NENHUM;
            SendClientMessage(playerid, -1, "Você saiu do emprego.");
        }
        return 1;
    }

    // EMPREGOS
    if(dialogid == DIALOG_EMPREGOS)
    {
        PlayerEmprego[playerid] = listitem + 1;
        SendClientMessage(playerid, -1, "Emprego assumido com sucesso!");
        return 1;
    }

    // GPS
if(dialogid == DIALOG_GPS)
{
    DisablePlayerCheckpoint(playerid);

    switch(listitem)
    {
        case 0:
        {
            SetPlayerCheckpoint(playerid, 1555.0, -1675.0, 16.2, 5.0);
        }
        case 1:
        {
            SetPlayerCheckpoint(playerid, -1987.0, 138.0, 27.6, 5.0);
        }
        case 2:
        {
            SetPlayerCheckpoint(playerid, 1377.0, 2329.0, 10.8, 5.0);
        }
    }

    SendClientMessage(playerid, 0x00FF00FF, "GPS marcado no mapa.");
    return 1;
}

// ================= COMANDOS =================
// Exemplo de comando usando zcmd
CMD:menu(playerid)
{
    if(!Logado[playerid]) return 1;
    AbrirMenuPrincipal(playerid);
    return 1;
}

CMD:prefeitura(playerid)
{
    if(!Logado[playerid]) return 1;
    AbrirPrefeitura(playerid);
    return 1;
}

CMD:gps(playerid)
{
    if(!Logado[playerid]) return 1;
    AbrirGPS(playerid);
    return 1;
}

// ================= ONPLAYERCOMMANDPERFORMED =================
public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if(!success)
    {
        SendClientMessage(playerid, 0xFF4444FF,
            "Comando inválido! Use /menu ou /ajuda para ver todos os comandos disponíveis.");
        return 1;
    }
    return 1;
}
