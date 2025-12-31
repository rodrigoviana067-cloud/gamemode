#if defined _player_data_included
    #endinput
#endif
#define _player_data_included

// ================= VARIÁVEIS =================
new bool:Logado[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];

// ================= FUNÇÕES =================
stock ContaPath(playerid, path[], size)
{
    format(path, size, "Contas/%d.ini", playerid);
}
