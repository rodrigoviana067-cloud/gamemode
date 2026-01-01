// include/commands.inc
public HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext[]) {
    // Retorna 0 para não bloquear outros diálogos
    return 0; 
}

CMD:gps(playerid, params[]) {
    if(!Logado[playerid]) return 1;
    new list[128];
    strcat(list, "Los Santos\nSan Fierro\nLas Venturas\nDesativar");
    ShowPlayerDialog(playerid, DIALOG_GPS_MENU, DIALOG_STYLE_LIST, "GPS Global", list, "Ok", "Sair");
    return 1;
}
