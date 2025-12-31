forward HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext[]);

CMD:menu(playerid, params[]) {
    if(!Logado[playerid]) return 1;
    ShowPlayerDialog(playerid, DIALOG_MENU_PRINCIPAL, DIALOG_STYLE_LIST, "Menu", "Prefeitura\nGPS", "Selecionar", "Fechar");
    return 1;
}

public HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == DIALOG_MENU_PRINCIPAL) {
        if(!response) return 1;
        if(listitem == 0) SendClientMessage(playerid, -1, "Você foi na Prefeitura.");
        return 1;
    }
    return 0;
}
