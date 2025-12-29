new bool:Logado[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];

// ================= PATH =================
stock ContaPath(playerid, path[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(path, size, "Contas/%s.ini", nome);
}

// ================= CONNECT / SPAWN =================
public OnPlayerConnect(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;

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
    if(!IsPlayerConnected(playerid) || !Logado[playerid]) return 1;

    new path[64];
    ContaPath(playerid, path, sizeof(path));
    dini_IntSet(path, "Emprego", PlayerEmprego[playerid]);
    return 1;
}

public OnPlayerSpawn(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;

    SetPlayerSkin(playerid, SPAWN_SKIN);
    SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    return 1;
}
