// include/commands.inc
forward HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext[]);

public HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext[]) {
    return 0;
}

CMD:gps(playerid, params[]) {
    if(!Logado[playerid]) return 1;
    
    new lista[200];
    lista[0] = '\0'; 
    strcat(lista, "Los Santos (LS)\n");
    strcat(lista, "San Fierro (SF)\n");
    strcat(lista, "Las Venturas (LV)\n");
    strcat(lista, "{00FF00}Agência de Empregos\n");
    strcat(lista, "{FFFF00}Lojas e Utilidades\n");
    strcat(lista, "{FF0000}Desativar GPS");

    ShowPlayerDialog(playerid, DIALOG_GPS_MENU, DIALOG_STYLE_LIST, "{00CCFF}GPS da Cidade", lista, "Selecionar", "Fechar");
    return 1;
}
