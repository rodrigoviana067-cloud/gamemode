public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
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
                    ShowPlayerDialog(playerid, DIALOG_EMPREGOS, DIALOG_STYLE_LIST,
                        "Empregos Disponíveis",
                        "Polícia\nSAMU\nTaxi\nMecânico\nLixeiro",
                        "Selecionar", "Voltar");
                }
            }
            else
            {
                if (listitem == 0)
                {
                    PlayerEmprego[playerid] = EMPREGO_NENHUM;
                    SendClientMessage(playerid, -1, "Você saiu do emprego.");
                }
            }
            return 1;
        }

        case DIALOG_EMPREGOS:
        {
            PlayerEmprego[playerid] = listitem + 1;
            SendClientMessage(playerid, 0x00FF00FF, "Emprego assumido com sucesso!");
            return 1;
        }

        case DIALOG_GPS:
        {
            DisablePlayerCheckpoint(playerid);

            switch (listitem)
            {
                case 0: SetPlayerCheckpoint(playerid, 1481.0, -1771.0, 18.8, 5.0);
                case 1: SetPlayerCheckpoint(playerid, 2131.0, -1150.0, 24.0, 5.0);
                case 2: SetPlayerCheckpoint(playerid, -2026.0, -96.0, 35.0, 5.0);
                case 3: SetPlayerCheckpoint(playerid, 1178.0, -1323.0, 14.1, 5.0);
                case 4: SetPlayerCheckpoint(playerid, 1555.0, -1675.0, 16.2, 5.0);
            }

            SendClientMessage(playerid, 0x00FF00FF, "GPS marcado no mapa.");
            return 1;
        }
    }
    return 1;
}
