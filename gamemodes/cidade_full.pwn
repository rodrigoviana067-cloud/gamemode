#include <a_samp>
#include <zcmd>
#include <dini>

#include "cfg_constants.inc"
#include "player_data.inc"
#include "menus.inc"
#include "commands.inc"

// ================= SALÁRIO =================
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

// ================= INIT =================
public OnGameModeInit()
{
    SetGameModeText("Cidade RP Full");
    SetTimer("PagamentoSalario", 600000, true);
    return 1;
}

main()
{
    print("Cidade Full carregada com sucesso.");
}
