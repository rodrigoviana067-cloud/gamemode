#include <a_samp>
#include <zcmd>
#include <dini>

// Definições de IDs (Garanta que sejam números diferentes)
#define DIALOG_LOGIN 1
#define DIALOG_REGISTER 2
#define DIALOG_MENU_PRINCIPAL 3
#define DIALOG_PREFEITURA 4
#define EMPREGO_NENHUM 0

// Variáveis Globais
new bool:Logado[MAX_PLAYERS];
new PlayerEmprego[MAX_PLAYERS];

// Carregar seus arquivos extras (Eles devem estar na pasta pawno/include)
#include "commands.inc" 

main() { print("Servidor Cidade RP Iniciado"); }

// Função para achar a conta do jogador
stock ContaPath(playerid, buffer[], len) {
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(buffer, len, "contas/%s.ini", name);
}

public OnPlayerConnect(playerid) {
    Logado[playerid] = false;
    new path[64];
    ContaPath(playerid, path, sizeof(path));
    if (dini_Exists(path)) {
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Digite sua senha:", "Entrar", "Sair");
    } else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registro", "Crie sua senha:", "Registrar", "Sair");
    }
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    // ESSA LINHA ABAIXO CHAMA OS COMANDOS DO SEU OUTRO ARQUIVO
    if (HandleDialogs_Commands(playerid, dialogid, response, listitem, inputtext)) return 1;

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    if(dialogid == DIALOG_LOGIN) {
        if(!response) return Kick(playerid);
        if(strcmp(inputtext, dini_Get(path, "Senha"), false) == 0) {
            Logado[playerid] = true;
            SpawnPlayer(playerid);
        } else {
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Senha errada!", "Entrar", "Sair");
        }
        return 1;
    }
    return 0;
}
