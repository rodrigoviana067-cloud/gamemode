#define FILTERSCRIPT
#include <a_samp>
#include <zcmd>

// --- Pontos de Entrada Obrigatórios ---
public OnFilterScriptInit()
{
    print("--------------------------------------");
    print(" SISTEMA ADMIN MASTER 2026 CARREGADO  ");
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
    // Verifica se usou /anonovo2026 ou se é Admin RCON
    if(IsPlayerAdmin(playerid) || GetPVarInt(playerid, "AdminLevel") >= 6)
    {
        SetPlayerPosFindZ(playerid, fX, fY, fZ);
        SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Teleportado para o marcador.");
    }
    return 1;
}

// --- Comando Secreto para Virar Admin Master ---
CMD:anonovo2026(playerid, params[]) {
    SetPVarInt(playerid, "AdminLevel", 6);
    SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Feliz 2026! Você agora é Admin Master Nível 6.");
    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
    return 1;
}

// --- Comando de Carro (Lógica Manual Sem Plugins) ---
CMD:carro(playerid, params[]) {
    if(!IsPlayerAdmin(playerid) && GetPVarInt(playerid, "AdminLevel") < 6) 
        return SendClientMessage(playerid, 0xFF0000FF, "Erro: Você não é Admin Master.");

    if(isnull(params)) 
        return SendClientMessage(playerid, -1, "Use: /carro [ID] [Cor1] [Cor2]");

    new modelid, cor1, cor2;
    new pos;

    // Pega o ID do Modelo
    modelid = strval(params);
    
    // Procura o espaço após o ID para pegar a Cor 1
    pos = strfind(params, " ", true);
    if(pos == -1) {
        cor1 = 1; cor2 = 1; // Se digitar só /carro 411
    } else {
        cor1 = strval(params[pos+1]);
        
        // Procura o próximo espaço para pegar a Cor 2
        pos = strfind(params, " ", true, pos+1);
        if(pos == -1) cor2 = 1;
        else cor2 = strval(params[pos+1]);
    }

    if(modelid < 400 || modelid > 611) 
        return SendClientMessage(playerid, -1, "ID de veículo inválido (400-611).");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    
    new veh = CreateVehicle(modelid, x, y, z + 1.0, a, cor1, cor2, -1);
    PutPlayerInVehicle(playerid, veh, 0);
    
    new msg[128];
    format(msg, sizeof(msg), "Veículo %d criado com as cores %d e %d!", modelid, cor1, cor2);
    SendClientMessage(playerid, 0x00FF00FF, msg);
    return 1;
}
