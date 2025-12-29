// ================= COMANDOS =================
CMD:menu(playerid)
{
    if(!IsPlayerConnected(playerid) || !Logado[playerid]) return 1;

    ShowPlayerDialog(playerid, DIALOG_MENU, DIALOG_STYLE_LIST,
        "Menu",
        "Prefeitura\nGPS",
        "Selecionar", "Fechar");
    return 1;
}

CMD:prefeitura(playerid)
{
    if(!IsPlayerConnected(playerid) || !Logado[playerid]) return 1;
    AbrirPrefeitura(playerid);
    return 1;
}

CMD:gps(playerid)
{
    if(!IsPlayerConnected(playerid) || !Logado[playerid]) return 1;
    AbrirGPS(playerid);
    return 1;
}

// ================= COMANDO INVALIDO =================
public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if(!IsPlayerConnected(playerid)) return 1;
    if(!success)
        SendClientMessage(playerid, 0xFF4444FF,
            "Comando inválido! Use /menu ou /ajuda para ver todos os comandos disponíveis.");
    return 1;
}
