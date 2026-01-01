// ==========================================================
// commands.inc - Cidade Full 2026
// ==========================================================

// Forward para que o arquivo principal reconheça a função
forward HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext[]);

// Definição da função (mesmo que vazia, evita erro de undefined symbol)
public HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext[]) {
    // Retornamos 0 para que o OnDialogResponse do arquivo principal continue o processamento
    return 0;
}

// Comando GPS Principal
CMD:gps(playerid, params[]) {
    if(!Logado[playerid]) return SendClientMessage(playerid, -1, "{FF0000}Erro: {FFFFFF}Você precisa estar logado!");
    
    new lista[256];
    lista[0] = '\0';
    strcat(lista, "Los Santos (LS)\n");
    strcat(lista, "San Fierro (SF)\n");
    strcat(lista, "Las Venturas (LV)\n");
    strcat(lista, "{00FF00}Agência de Empregos\n");
    strcat(lista, "{FFFF00}Lojas e Utilidades\n");
    strcat(lista, "{FF0000}Desativar GPS");

    ShowPlayerDialog(playerid, DIALOG_GPS_MENU, DIALOG_STYLE_LIST, "{00CCFF}GPS - Cidade Full", lista, "Selecionar", "Fechar");
    return 1;
}

// Comando de Ajuda para os Comandos da Cidade
CMD:ajuda(playerid, params[]) {
    SendClientMessage(playerid, -1, "{00CCFF}================ Comandos Cidade Full ================");
    SendClientMessage(playerid, -1, "{FFFF00}/gps {FFFFFF}- Abre o menu de navegação da cidade.");
    SendClientMessage(playerid, -1, "{FFFF00}/empregos {FFFFFF}- Escolha sua profissão na agência.");
    SendClientMessage(playerid, -1, "{FFFF00}/info {FFFFFF}- Mostra suas informações atuais.");
    SendClientMessage(playerid, -1, "{00CCFF}======================================================");
    return 1;
}

// Comando para ver as próprias estatísticas
CMD:info(playerid, params[]) {
    new msg[128];
    format(msg, sizeof(msg), "{FFFFFF}Dinheiro no Banco: {00FF00}$%d {FFFFFF}| Emprego ID: {FFFF00}%d", PlayerMoney[playerid], PlayerEmprego[playerid]);
    SendClientMessage(playerid, -1, msg);
    return 1;
}
