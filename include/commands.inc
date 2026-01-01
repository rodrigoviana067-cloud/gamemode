// include/commands.inc
forward HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext[]);
forward cmd_gps(playerid, params[]); // Forward necessário para ser chamado de volta

public HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext[]) {
    // Este arquivo só tem o GPS agora.
    return 0;
}

CMD:gps(playerid, params[]) {
    if(!Logado[playerid]) return 1;
    
    new lista;
    strcat(lista, "Los Santos (LS)\n");
    strcat(lista, "San Fierro (SF)\n");
    strcat(lista, "Las Venturas (LV)\n");
    strcat(lista, "{00FF00}Agência de Empregos\n");
    strcat(lista, "{FFFF00}Lojas e Utilidades\n");
    strcat(lista, "{FF0000}Desativar GPS");

    ShowPlayerDialog(playerid, DIALOG_GPS_MENU, DIALOG_STYLE_LIST, "{00CCFF}GPS da Cidade", lista, "Selecionar", "Fechar");
    return 1;
}

// Removido o CMD:banco daqui, pois agora usamos um pickup no mapa.
