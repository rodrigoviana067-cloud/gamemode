CMD:menu(playerid)
{
    if(!Logado[playerid]) return 1;
    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,
        "Menu",
        "Prefeitura\nGPS",
        "Selecionar", "Fechar");
    return 1;
}

CMD:prefeitura(playerid)
{
    if(!Logado[playerid]) return 1;
    AbrirPrefeitura(playerid);
    return 1;
}

CMD:gps(playerid)
{
    if(!Logado[playerid]) return 1;
    AbrirGPS(playerid);
    return 1;
}
