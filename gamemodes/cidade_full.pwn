main() 
{
    print("Servidor Iniciado com Sucesso");
}

#include <a_samp>
#include <zcmd>
#include <dini>

#include "cfg_constants.inc"   // defines gerais (cores, dialogs, empregos, posições)
#include "player_data.inc"     // variáveis globais (Logado, PlayerEmprego, enums)
#include "menus.inc"           // stocks de menus (ShowPlayerDialog)
#include "commands.inc"        // OnDialogResponse + comandos

public OnGameModeInit()
{
    SetGameModeText("Cidade RP Full");
    SetTimer("PagamentoSalario", 600000, true);
    return 1;
}

forward PagamentoSalario();
public PagamentoSalario()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i) && Logado[i] && PlayerEmprego[i] != EMPREGO_NENHUM)
        {
            GivePlayerMoney(i, 1000);
            SendClientMessage(i, 0x00FF00FF, "Salário recebido.");
        }
    }
    return 1;
}
