#include <a_samp>
#include <zcmd>
#include <dini>

// Definições de IDs
#define DIALOG_LOGIN 1
#define DIALOG_REGISTER 2
#define DIALOG_MENU_PRINCIPAL 3
#define DIALOG_PREFEITURA 4
#define EMPREGO_NENHUM 0

// Variáveis Globais
new bool:Logado[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];

// Carregar comandos externos
#include "commands.inc" 

main() { 
    print("----------------------------------");
    print(" Servidor Cidade RP Iniciado 2026 ");
    print("----------------------------------");
}

public OnGameModeInit() {
    // Define uma skin padrão e posição inicial (Spawn Civil)
    AddPlayerClass(26, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
    return 1;
}

// Função para achar o caminho do arquivo da conta
stock ContaPath(playerid, buffer[], len) {
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(buffer, len, "contas/%s.ini", name);
}

public OnPlayerConnect(playerid) {
    Logado[playerid] = false;
    new path[64];
    ContaPath(playerid, path, sizeof(path));
    
    // Pequeno delay para garantir que o jogador carregou a tela antes do diálogo
    SetTimerEx("MostrarLogin", 1000, false, "i", playerid);
    return 1;
}

forward MostrarLogin(playerid);
public MostrarLogin(playerid) {
    new path[64];
    ContaPath(playerid, path, sizeof(path));
    
    if (dini_Exists(path)) {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login - Cidade RP", "Esta conta existe.\nDigite sua senha abaixo:", "Entrar", "Sair");
    } else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registro - Cidade RP", "Bem-vindo!\nCrie uma senha para se registrar:", "Registrar", "Sair");
    }
}

// CORREÇÃO DO TRAVAMENTO: Pular seleção de classe se estiver logado
public OnPlayerRequestClass(playerid, classid) {
    if(Logado[playerid] == true) {
        SpawnPlayer(playerid);
        return 1;
    }
    // Posiciona a câmera em um lugar bonito enquanto ele loga
    SetPlayerPos(playerid, 1550.0, -1600.0, 30.0);
    SetPlayerCameraPos(playerid, 1550.0, -1650.0, 50.0);
    SetPlayerCameraLookAt(playerid, 1550.0, -1600.0, 30.0);
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    // Processa diálogos do arquivo commands.inc primeiro
    if (HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext)) return 1;

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    // Lógica de Registro
    if(dialogid == DIALOG_REGISTER) {
        if(!response) return Kick(playerid);
        if(strlen(inputtext) < 4) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Erro", "Senha muito curta! (Mínimo 4 caracteres)", "Registrar", "Sair");
        
        dini_Create(path);
        dini_Set(path, "Senha", inputtext);
        dini_IntSet(path, "Emprego", EMPREGO_NENHUM);
        
        // Coordenadas iniciais para novos jogadores (Prefeitura/Spawn)
        dini_FloatSet(path, "Pos_X", 1958.3783);
        dini_FloatSet(path, "Pos_Y", 1343.1572);
        dini_FloatSet(path, "Pos_Z", 15.3746);
        
        Logado[playerid] = true;
        SendClientMessage(playerid, -1, "Conta criada com sucesso! Bem-vindo.");
        SpawnPlayer(playerid);
        return 1;
    }

    // Lógica de Login
    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        
        if(strcmp(inputtext, dini_Get(path, "Senha"), false) == 0) {
            PlayerEmprego[playerid] = dini_Int(path, "Emprego");
            Logado[playerid] = true;
            SendClientMessage(playerid, -1, "Login realizado com sucesso!");
            SpawnPlayer(playerid);
        } else {
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Erro", "Senha incorreta!\nTente novamente:", "Entrar", "Sair");
        }
        return 1;
    }
    return 0;
}

public OnPlayerDisconnect(playerid, reason) {
    if(Logado[playerid] == true) {
        new path[64];
        ContaPath(playerid, path, sizeof(path));
        
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z); // Pega a posição atual antes de sair
        
        dini_IntSet(path, "Emprego", PlayerEmprego[playerid]);
        dini_FloatSet(path, "Pos_X", x);
        dini_FloatSet(path, "Pos_Y", y);
        dini_FloatSet(path, "Pos_Z", z);
    }
    Logado[playerid] = false;
    return 1;
}

public OnPlayerSpawn(playerid) {
    if(!Logado[playerid]) {
        Kick(playerid); 
        return 0;
    }
    
    new path[64];
    ContaPath(playerid, path, sizeof(path));
    
    // Carrega a posição do arquivo se ela existir
    if(dini_Exists(path)) {
        new Float:x, Float:y, Float:z;
        x = dini_Float(path, "Pos_X");
        y = dini_Float(path, "Pos_Y");
        z = dini_Float(path, "Pos_Z");
        
        if(x != 0.0) { // Evita spawnar no 0,0,0 caso o arquivo esteja bugado
            SetPlayerPos(playerid, x, y, z);
        }
    }

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    return 1;
}
