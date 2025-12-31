main()
{
    print("Cidade RP Full carregada com sucesso");
}

#include <a_samp>
#include <zcmd>
#include <dini>

#include "cfg_constants.inc"
#include "player_data.inc"
#include "menus.inc"
#include "commands.inc"

public OnGameModeInit()
{
    SetGameModeText("Cidade RP Full");
    SetTimer("PagamentoSalario", 600000, true);
    return 1;
}

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
            "Login",
            "Digite sua senha:",
            "Entrar", "Sair");
    }
    else
    {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
            "Registro",
            "Crie sua senha:",
            "Registrar", "Sair");
    }
    return 1;
}
