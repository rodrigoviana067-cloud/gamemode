HandleDialogs_Comands(playerid, dialogid, response, listitem, inputtext[])
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
                    // lógica aqui
                }
            }
            return 1;
        }
    }
    return 0; // importante
}
