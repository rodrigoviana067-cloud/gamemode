#if defined _menus_included
    #endinput
#endif
#define _menus_included

// ================= DIALOG IDS =================
#define DIALOG_MENU_PRINCIPAL  100
#define DIALOG_PREFEITURA      110
#define DIALOG_EMPREGOS        111
#define DIALOG_GPS             120
#define DIALOG_AJUDA           130

// ================= MENUS =================
stock AbrirMenuPrincipal(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_MENU_PRINCIPAL, DIALOG_STYLE_LIST,
        "Menu da Cidade",
        "Prefeitura\nConcessionária\nAuto Escola\nGPS\nAjuda",
        "Selecionar", "Fechar");
    return 1;
}

stock AbrirPrefeitura(playerid)
{
    if (PlayerEmprego[playerid] == EMPREGO_NENHUM)
    {
        ShowPlayerDialog(playerid, DIALOG_PREFEITURA, DIALOG_STYLE_LIST,
            "Prefeitura",
            "Ver Empregos",
            "Selecionar", "Fechar");
    }
    else
    {
        ShowPlayerDialog(playerid, DIALOG_PREFEITURA, DIALOG_STYLE_LIST,
            "Prefeitura",
            "Sair do Emprego",
            "Selecionar", "Fechar");
    }
    return 1;
}

stock AbrirGPS(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST,
        "GPS",
        "Prefeitura\nConcessionária\nAuto Escola\nHospital\nDelegacia",
        "Marcar", "Fechar");
    return 1;
}

stock AbrirAjuda(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_AJUDA, DIALOG_STYLE_MSGBOX,
        "Ajuda",
        "/menu - Menu principal\n\
/gps - GPS da cidade\n\
/prefeitura - Prefeitura\n\
/ajuda - Este menu",
        "Ok", "");
    return 1;
}
