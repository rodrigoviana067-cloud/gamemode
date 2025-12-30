stock AbrirPrefeitura(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_PREFEITURA, DIALOG_STYLE_LIST,
        "Prefeitura",
        "Ver Empregos\nSair do Emprego",
        "Selecionar", "Fechar");
    return 1;
}

stock AbrirGPS(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST,
        "GPS",
        "Prefeitura LS\nPrefeitura SF\nPrefeitura LV",
        "Marcar", "Cancelar");
    return 1;
}

stock AbrirMenuPrincipal(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,
        "Menu",
        "Prefeitura\nGPS",
        "Selecionar", "Fechar");
    return 1;
}
