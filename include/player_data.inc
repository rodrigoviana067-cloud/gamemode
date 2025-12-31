#if defined _player_data_included
    #endinput
#endif
#define _player_data_included

// ================= VARIÁVEIS =================
new bool:Logado[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];

// ================= FUNÇÕES =================
ContaPath(playerid, path[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    format(path, size, "Contas/%s.ini", nome);
    return 1;
}

