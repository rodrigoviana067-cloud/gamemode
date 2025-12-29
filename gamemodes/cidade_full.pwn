#include <a_samp>
#include <zcmd>
#include <dini>

// INCLUDES DO PROJETO
#include "cfg_constants.inc"
#include "player_data.inc"
#include "menus.inc"
#include "commands.inc"
#include "salario.inc"

// ================= ENTRY POINT =================
public OnGameModeInit()
{
    SetGameModeText("Cidade RP Full");
    SetTimer("PagamentoSalario", 600000, true); // 10 minutos

    print("Cidade Full carregada com sucesso.");
    return 1;
}

public OnGameModeExit()
{
    print("Cidade Full encerrada.");
    return 1;
}

// Mensagem de comando inválido
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
