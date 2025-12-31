// ================= COMANDOS =================

CMD:menu(playerid)
{
    if (!Logado[playerid])
        return SendClientMessage(playerid, -1, "❌ Você precisa logar primeiro.");

    ShowPlayerDialog(playerid, DIALOG_MENU_PRINCIPAL, DIALOG_STYLE_LIST,
        "Menu Principal",
        "Prefeitura\nConcessionária\nAuto Escola\nGPS\nAjuda",
        "Selecionar", "Fechar");
    return 1;
}

CMD:prefeitura(playerid)
{
    if (!Logado[playerid])
        return SendClientMessage(playerid, -1, "❌ Você precisa logar primeiro.");

    AbrirPrefeitura(playerid);
    return 1;
}

CMD:gps(playerid)
{
    if (!Logado[playerid])
        return SendClientMessage(playerid, -1, "❌ Você precisa logar primeiro.");

    AbrirGPS(playerid);
    return 1;
}

CMD:ajuda(playerid)
{
    if (!Logado[playerid])
        return SendClientMessage(playerid, -1, "❌ Você precisa logar primeiro.");

    AbrirAjuda(playerid);
    return 1;
}

// ================= DIALOG HANDLER =================

HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext[])
{
    if (!response) return 1;

    switch (dialogid)
    {
        case DIALOG_MENU_PRINCIPAL:
        {
            switch (listitem)
            {
                case 0: AbrirPrefeitura(playerid);
                case 1: SendClientMessage(playerid, -1, "📍 Concessionária em Los Santos.");
                case 2: SendClientMessage(playerid, -1, "📍 Auto Escola disponível.");
                case 3: AbrirGPS(playerid);
                case 4: AbrirAjuda(playerid);
            }
            return 1;
        }

        case DIALOG_PREFEITURA:
        {
            if (PlayerEmprego[playerid] == EMPREGO_NENHUM)
            {
                if (listitem == 0)
                {
                    SendClientMessage(playerid, -1, "Você pegou um emprego!");
                }
            }
            return 1;
        }
    }
    return 0;
}
