// commands.inc corrigido para 2026

forward HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext[]);

CMD:menu(playerid, params[]) {
    if(!Logado[playerid]) return 1;
    ShowPlayerDialog(playerid, DIALOG_MENU_PRINCIPAL, DIALOG_STYLE_LIST, "Menu Principal", "Prefeitura\nGPS da Cidade", "Selecionar", "Fechar");
    return 1;
}

public HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == DIALOG_MENU_PRINCIPAL) {
        if(!response) return 1;
        
        if(listitem == 0) { // Prefeitura
            SendClientMessage(playerid, -1, "Você selecionou a Prefeitura.");
        }
        if(listitem == 1) { // GPS
            // Mudança aqui: usamos uma string vazia declarada para evitar o warning 239
            new fparams[1]; 
            return cmd_gps(playerid, fparams); 
        }
        return 1;
    }
    return 0;
}

CMD:gps(playerid, params[]) {
    if(!Logado[playerid]) return SendClientMessage(playerid, -1, "{FF0000}Erro: {FFFFFF}Você não está logado.");
    
    new lista[150];
    lista[0] = 0; // Limpa a string antes de usar o strcat
    strcat(lista, "Los Santos (LS)\n");
    strcat(lista, "San Fierro (SF)\n");
    strcat(lista, "Las Venturas (LV)\n");
    strcat(lista, "{FF0000}Desativar GPS");

    ShowPlayerDialog(playerid, DIALOG_GPS_MENU, DIALOG_STYLE_LIST, "GPS - Selecione a Região", lista, "Selecionar", "Fechar");
    return 1;
}
