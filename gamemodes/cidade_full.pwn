public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(!response) return 1;

    switch(dialogid)
    {
        case DIALOG_MENU:
        {
            if(listitem == 0) AbrirPrefeitura(playerid);
            else if(listitem == 1) AbrirGPS(playerid);
        }

        case DIALOG_PREFEITURA:
        {
            if(listitem == 0)
            {
                ShowPlayerDialog(playerid, DIALOG_EMPREGOS, DIALOG_STYLE_LIST,
                    "Empregos",
                    "Polícia\nSAMU\nTaxi\nMecânico",
                    "Selecionar", "Voltar");
            }
            else if(listitem == 1)
            {
                PlayerEmprego[playerid] = EMPREGO_NENHUM;
                SendClientMessage(playerid, -1, "Você saiu do emprego.");
            }
        }

        case DIALOG_EMPREGOS:
        {
            PlayerEmprego[playerid] = listitem + 1;
            SendClientMessage(playerid, -1, "Emprego assumido com sucesso!");
        }

        case DIALOG_GPS:
        {
            DisablePlayerCheckpoint(playerid);

            switch(listitem)
            {
                case 0:
                    SetPlayerCheckpoint(1555.0, -1675.0, 16.2, 5.0);
                case 1:
                    SetPlayerCheckpoint(-1987.0, 138.0, 27.6, 5.0);
                case 2:
                    SetPlayerCheckpoint(1377.0, 2329.0, 10.8, 5.0);
            }

            SendClientMessage(playerid, 0x00FF00FF, "GPS marcado no mapa.");
        }
    }
    return 1;
}
