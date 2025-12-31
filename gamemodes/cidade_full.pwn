#include <a_samp>
#include <zcmd>
#include <dini>

// ================= INCLUDES DO PROJETO =================
#include "cfg_constants.inc"
#include "player_data.inc"
#include "menus.inc"
#include "commands.inc"

// ================= VARIÁVEIS =================
new bool:Logado[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];

public OnGameModeInit()
{
    SetGameModeText("Cidade RP Full");
    SetTimer("PagamentoSalario", 600000, true);
    return 1;
}

public OnPlayerConnect(playerid) { ... }
public OnPlayerDisconnect(playerid, reason) { ... }
public OnPlayerSpawn(playerid) { ... }
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) { ... }

forward PagamentoSalario();
public PagamentoSalario()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Logado[i] && PlayerEmprego[i] != EMPREGO_NENHUM)
        {
            GivePlayerMoney(i, 1000);
            SendClientMessage(i, 0x00FF00FF, "Salário recebido.");
        }
    }
    return 1;
}

CMD:menu(playerid)
{
    if(!Logado[playerid]) return 1;
    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,
        "Menu",
        "Prefeitura\nGPS",
        "Selecionar", "Fechar");
    return 1;
}
