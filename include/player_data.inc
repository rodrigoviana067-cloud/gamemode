new bool:Logado[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];

// ===== PATH =====
stock ContaPath(playerid, path[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(path, size, "Contas/%s.ini", nome);
}
