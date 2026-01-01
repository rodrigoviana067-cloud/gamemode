#include <a_samp>
#include <zcmd>
#include <dini>
#include <sscanf2> // Necessário para a função Transferir do banco

// Definições de IDs de Diálogo
#define DIALOG_LOGIN        1
#define DIALOG_REGISTER     2
#define DIALOG_GPS_MENU     500
#define DIALOG_GPS_LS       501
#define DIALOG_GPS_SF       502
#define DIALOG_GPS_LV       503
#define DIALOG_GPS_EMPREGOS 504
#define DIALOG_GPS_LOJAS    505
#define DIALOG_BANK_MENU    600
#define DIALOG_BANK_SACAR   601
#define DIALOG_BANK_DEPOSITAR 602
#define DIALOG_BANK_TRANSFERIR 603

#define EMPREGO_NENHUM      0

// Variáveis Globais
new bool:Logado[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];
new PlayerMoney[MAX_PLAYERS]; // Dinheiro no banco

// Carregar comandos externos (Inclui /gps)
#include "commands.inc" 

main() { 
    print("----------------------------------");
    print(" Servidor Cidade RP Iniciado 2026 ");
    print("----------------------------------");
}

public OnGameModeInit() {
    AddPlayerClass(26, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);

    // PICKUPS DOS BANCOS (ID 1274 é o ícone de cofre)
    CreatePickup(1274, 1, 1467.0, -1010.0, 26.0, -1); // Banco LS
    CreatePickup(1274, 1, -2416.0, 508.0, 35.0, -1);  // Banco SF
    CreatePickup(1274, 1, 2372.0, 2311.0, 10.0, -1);  // Banco LV

    return 1;
}

// NOVO CALLBACK: Acessar banco pelo pickup
public OnPlayerPickUpPickup(playerid, pickupid) {
    if(!Logado[playerid]) return 1;

    // Se o pickup for de banco, abrir menu
    if (pickupid == 1274) { // ID do pickup de cofre
        new lista;
        format(lista, sizeof(lista), "{FFFFFF}Você tem {00FF00}$%d {FFFFFF}no banco e {00FF00}$%d {FFFFFF}no bolso.\n\n{FFFFFF}Escolha uma opção:", 
            PlayerMoney[playerid], GetPlayerMoney(playerid));
        
        strcat(lista, "Sacar Dinheiro\n");
        strcat(lista, "Depositar Dinheiro\n");
        strcat(lista, "Transferir Dinheiro\n");

        ShowPlayerDialog(playerid, DIALOG_BANK_MENU, DIALOG_STYLE_LIST, "Banco Central RP", lista, "Selecionar", "Fechar");
    }
    return 1;
}

// Detecção de Comando Inexistente (Mensagem Bonita)
public OnPlayerCommandPerformed(playerid, cmdtext[], success) {
    if(!success) {
        SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}>> {FFFFFF}O comando que você digitou não existe em nossa base de dados.");
        SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}>> {FFFFFF}Use {FFFF00}/gps {FFFFFF}para navegar pela cidade.");
    }
    return 1;
}

stock ContaPath(playerid, buffer[], len) {
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(buffer, len, "contas/%s.ini", name);
}

public OnPlayerConnect(playerid) {
    Logado[playerid] = false;
    SetTimerEx("MostrarLogin", 1000, false, "i", playerid);
    return 1;
}

forward MostrarLogin(playerid);
public MostrarLogin(playerid) {
    new path;
    ContaPath(playerid, path, sizeof(path));
    if (dini_Exists(path)) {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{00CCFF}Login - Cidade RP", "{FFFFFF}Bem-vindo de volta!\n\n{FFFFFF}Digite sua senha abaixo para entrar:", "Entrar", "Sair");
    } else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "{00CCFF}Registro - Cidade RP", "{FFFFFF}Você é novo por aqui!\n\n{FFFFFF}Crie uma senha segura para sua conta:", "Registrar", "Sair");
    }
}

public OnPlayerRequestClass(playerid, classid) {
    if(Logado[playerid]) {
        SpawnPlayer(playerid);
        return 1;
    }
    SetPlayerPos(playerid, 1550.0, -1600.0, 30.0);
    SetPlayerCameraPos(playerid, 1550.0, -1650.0, 50.0);
    SetPlayerCameraLookAt(playerid, 1550.0, -1600.0, 30.0);
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if (HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext)) return 1;

    new path;
    ContaPath(playerid, path, sizeof(path));

    if(dialogid == DIALOG_REGISTER) {
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 4) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Erro", "Senha muito curta!", "Registrar", "Sair");
        
        dini_Create(path);
        dini_Set(path, "Senha", inputtext);
        dini_IntSet(path, "Emprego", EMPREGO_NENHUM);
        dini_FloatSet(path, "Pos_X", 1958.3783);
        dini_FloatSet(path, "Pos_Y", 1343.1572);
        dini_FloatSet(path, "Pos_Z", 15.3746);
        dini_IntSet(path, "DinheiroBanco", 0); // Define 0 no banco ao criar conta
        
        Logado[playerid] = true;
        SpawnPlayer(playerid);
        return 1;
    }

    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        if(strcmp(inputtext, dini_Get(path, "Senha"), false) == 0) {
            PlayerEmprego[playerid] = dini_Int(path, "Emprego");
            PlayerMoney[playerid] = dini_Int(path, "DinheiroBanco"); // Carrega dinheiro
            GivePlayerMoney(playerid, 500); // Dinheiro inicial no bolso
            Logado[playerid] = true;
            SpawnPlayer(playerid);
        } else {
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Erro", "Senha incorreta!", "Entrar", "Sair");
        }
        return 1;
    }

    // Lógicas dos Diálogos do BANCO
    if (dialogid == DIALOG_BANK_SACAR) {
        if (!response) return 1;
        new quantia = strval(inputtext);
        if (quantia <= 0 || quantia > PlayerMoney[playerid]) return SendClientMessage(playerid, -1, "{FF0000}Valor inválido ou insuficiente no banco!");
        PlayerMoney[playerid] -= quantia;
        GivePlayerMoney(playerid, quantia);
        SendClientMessage(playerid, -1, "{00FF00}Você sacou R$ %d.", quantia);
        return 1;
    }
    if (dialogid == DIALOG_BANK_DEPOSITAR) {
        if (!response) return 1;
        new quantia = strval(inputtext);
        if (quantia <= 0 || quantia > GetPlayerMoney(playerid)) return SendClientMessage(playerid, -1, "{FF0000}Valor inválido ou insuficiente no bolso!");
        PlayerMoney[playerid] += quantia;
        GivePlayerMoney(playerid, -quantia);
        SendClientMessage(playerid, -1, "{00FF00}Você depositou R$ %d.", quantia);
        return 1;
    }
    if (dialogid == DIALOG_BANK_TRANSFERIR) {
        if (!response) return 1;
        new targetid, quantia;
        if(sscanf(inputtext, "ud", targetid, quantia)) { // Lê ID e Valor
            if (targetid == playerid) return SendClientMessage(playerid, -1, "{FF0000}Você não pode transferir para si mesmo!");
            if (!IsPlayerConnected(targetid) || !Logado[targetid]) return SendClientMessage(playerid, -1, "{FF0000}Jogador offline ou não logado.");
            if (quantia <= 0 || quantia > PlayerMoney[playerid]) return SendClientMessage(playerid, -1, "{FF0000}Valor inválido ou insuficiente no banco!");

            PlayerMoney[playerid] -= quantia;
            PlayerMoney[targetid] += quantia;
            SendClientMessage(playerid, -1, "{00FF00}Você transferiu R$ %d para o ID %d.", quantia, targetid);
            SendClientMessage(targetid, -1, "{00FF00}Você recebeu R$ %d do ID %d.", quantia, playerid);
        } else {
            SendClientMessage(playerid, -1, "{FF0000}Formato incorreto. Use: ID VALOR");
        }
        return 1;
    }
    
    // --- SISTEMA DE GPS REVISADO ---
    if(dialogid == DIALOG_GPS_MENU) {
        if(!response) return 1;
        switch(listitem) {
            case 0: ShowPlayerDialog(playerid, DIALOG_GPS_LS, DIALOG_STYLE_LIST, "GPS - Los Santos", "Prefeitura\nBanco Central\nDP\nHospital\nAeroporto", "Marcar", "Voltar");
            case 1: ShowPlayerDialog(playerid, DIALOG_GPS_SF, DIALOG_STYLE_LIST, "GPS - San Fierro", "Banco SF\nDP SF\nHospital SF\nAeroporto SF", "Marcar", "Voltar");
            case 2: ShowPlayerDialog(playerid, DIALOG_GPS_LV, DIALOG_STYLE_LIST, "GPS - Las Venturas", "Banco LV\nCassino\nDP LV\nAeroporto LV", "Marcar", "Voltar");
            case 3: ShowPlayerDialog(playerid, DIALOG_GPS_EMPREGOS, DIALOG_STYLE_LIST, "GPS - Empregos", "Caminhoneiro\nTaxista\nEntregador de Pizza\nLixeiro", "Marcar", "Voltar");
            case 4: ShowPlayerDialog(playerid, DIALOG_GPS_LOJAS, DIALOG_STYLE_LIST, "GPS - Lojas", "Concessionária\nLoja de Armas\n24/7\nMecânica", "Marcar", "Voltar");
            case 5: { DisablePlayerCheckpoint(playerid); SendClientMessage(playerid, -1, "{FF0000}GPS Desativado."); }
        }
        return 1;
    }

    // Processamento de todos os sub-menus do GPS
    if(dialogid >= 501 && dialogid <= 505) {
        if(!response) { new t; return cmd_gps(playerid, t); } // Voltar ao menu principal
        DisablePlayerCheckpoint(playerid);
        
        switch(dialogid) {
            case DIALOG_GPS_LS: {
                switch(listitem) {
                    case 0: SetPlayerCheckpoint(playerid, 1481.0, -1741.0, 13.5, 4.0);
                    case 1: SetPlayerCheckpoint(playerid, 1467.0, -1010.0, 26.0, 4.0);
                    case 2: SetPlayerCheckpoint(playerid, 1543.0, -1675.0, 13.5, 4.0);
                    case 3: SetPlayerCheckpoint(playerid, 1172.0, -1323.0, 14.0, 4.0);
                    case 4: SetPlayerCheckpoint(playerid, 1958.0, -2173.0, 13.5, 4.0);
                }
            }
            case DIALOG_GPS_SF: {
                switch(listitem) {
                    case 0: SetPlayerCheckpoint(playerid, -2416.0, 508.0, 35.0, 4.0);  // Banco SF
                    case 1: SetPlayerCheckpoint(playerid, -1605.0, 711.0, 13.0, 4.0);  // DP SF
                    case 2: SetPlayerCheckpoint(playerid, -2646.0, 630.0, 14.0, 4.0);  // Hosp SF
                    case 3: SetPlayerCheckpoint(playerid, -1420.0, -287.0, 14.0, 4.0); // Aero SF
                }
            }
            case DIALOG_GPS_LV: {
                switch(listitem) {
                    case 0: SetPlayerCheckpoint(playerid, 2372.0, 2311.0, 10.0, 4.0);  // Banco LV (Posição ajustada para ficar em cima)
                    case 1: SetPlayerCheckpoint(playerid, 2191.0, 1677.0, 12.0, 4.0);  // Cassino
                    case 2: SetPlayerCheckpoint(playerid, 2290.0, 2431.0, 10.0, 4.0);  // DP LV
                    case 3: SetPlayerCheckpoint(playerid, 1585.0, 1445.0, 10.0, 4.0);  // Aero LV
                }
            }
            case DIALOG_GPS_EMPREGOS: {
                switch(listitem) {
                    case 0: SetPlayerCheckpoint(playerid, 2458.0, -2121.0, 13.5, 4.0); // Caminhoneiro
                    case 1: SetPlayerCheckpoint(playerid, 1782.0, -1153.0, 23.0, 4.0); // Taxista
                    case 2: SetPlayerCheckpoint(playerid, 2105.0, -1806.0, 13.5, 4.0); // Pizza
                    case 3: SetPlayerCheckpoint(playerid, 2185.0, -1974.0, 13.5, 4.0); // Lixeiro
                }
            }
            case DIALOG_GPS_LOJAS: {
                switch(listitem) {
                    case 0: SetPlayerCheckpoint(playerid, 2131.0, -1150.0, 24.0, 4.0); // Concessionaria
                    case 1: SetPlayerCheckpoint(playerid, 1368.0, -1279.0, 13.5, 4.0); // Ammu
                    case 2: SetPlayerCheckpoint(playerid, 1315.0, -897.0, 39.5, 4.0);  // 24/7
                    case 3: SetPlayerCheckpoint(playerid, 2439.0, -1471.0, 24.0, 4.0); // Mecanica
                }
            }
        }
        SendClientMessage(playerid, 0xFFFF00FF, "GPS: Local marcado! Siga a marca vermelha no minimapa.");
        return 1;
    }
    return 0;
}

public OnPlayerDisconnect(playerid, reason) {
    if(Logado[playerid]) {
        new path, Float:x, Float:y, Float:z;
        ContaPath(playerid, path, sizeof(path));
        GetPlayerPos(playerid, x, y, z);
        dini_IntSet(path, "Emprego", PlayerEmprego[playerid]);
        dini_FloatSet(path, "Pos_X", x);
        dini_FloatSet(path, "Pos_Y", y);
        dini_FloatSet(path, "Pos_Z", z);
        dini_IntSet(path, "DinheiroBanco", PlayerMoney[playerid]); // Salva dinheiro do banco
    }
    Logado[playerid] = false;
    return 1;
}

public OnPlayerSpawn(playerid) {
    if(!Logado[playerid]) return Kick(playerid);
    
    new path;
    ContaPath(playerid, path, sizeof(path));
    if(dini_Exists(path)) {
        new Float:x = dini_Float(path, "Pos_X");
        new Float:y = dini_Float(path, "Pos_Y");
        new Float:z = dini_Float(path, "Pos_Z");
        if(x != 0.0) SetPlayerPos(playerid, x, y, z);
        else SetPlayerPos(playerid, 1958.37, 1343.15, 15.37); // Spawn padrão se bugado
    }
    SetPlayerInterior(playerid, 0);
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    DisablePlayerCheckpoint(playerid);
    SendClientMessage(playerid, -1, "{00FF00}GPS: {FFFFFF}Você chegou ao seu destino final.");
    PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
    return 1;
}
