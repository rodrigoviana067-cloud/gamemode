// include/commands.inc

public HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext[]) {
    return 0; // Deixa o script principal processar os diálogos
}

CMD:gps(playerid, params[]) {
    if(!Logado[playerid]) return 1;
    new lista[128];
    strcat(lista, "Los Santos (LS)\nSan Fierro (SF)\nLas Venturas (LV)\nDesativar GPS");
    ShowPlayerDialog(playerid, DIALOG_GPS_MENU, DIALOG_STYLE_LIST, "GPS Global", lista, "Selecionar", "Sair");
    return 1;
}
