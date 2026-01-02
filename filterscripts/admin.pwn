#define FILTERSCRIPT
#include <a_samp>
#include <zcmd>
#include <sscanf2>

// Sistema de Teleporte ao Marcar o Mapa
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if(IsPlayerAdmin(playerid) || GetPVarInt(playerid, "AdminLevel") >= 6)
    {
        SetPlayerPosFindZ(playerid, fX, fY, fZ);
        SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Teleportado para o marcador.");
    }
    return 1;
}

// Comando para virar Admin Master
CMD:adminmaster2026(playerid, params[]) {
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));

    // COLOQUE SEU NOME AQUI
    if(strcmp(name, "Seu_Nome", true) == 0 || IsPlayerAdmin(playerid)) {
        SetPVarInt(playerid, "AdminLevel", 6);
        SendClientMessage(playerid, 0x00FF00FF, "[SUCESSO] Você agora é Admin Master Nível 6.");
    } else {
        SendClientMessage(playerid, 0xFF0000FF, "[ERRO] Sem permissão.");
    }
    return 1;
}

// Comando para Criar Carro
CMD:carro(playerid, params[]) {
    if(!IsPlayerAdmin(playerid) && GetPVarInt(playerid, "AdminLevel") < 1) 
        return SendClientMessage(playerid, -1, "Apenas Admins.");

    new modelid, cor1, cor2;
    if(sscanf(params, "ddd", modelid, cor1, cor2)) 
        return SendClientMessage(playerid, -1, "Use: /carro [ID] [Cor1] [Cor2]");

    if(modelid < 400 || modelid > 611) return SendClientMessage(playerid, -1, "ID Inválido.");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    
    new veh = CreateVehicle(modelid, x, y, z, a, cor1, cor2, -1);
    PutPlayerInVehicle(playerid, veh, 0);
    SendClientMessage(playerid, 0xFFFF00FF, "Veículo criado!");
    return 1;
}

// Evento Ano Novo 2026
CMD:anonovo2026(playerid, params[]) {
    new ano, mes, dia;
    getdate(ano, mes, dia);
    if(ano == 2026 && mes == 1) { 
        SendClientMessage(playerid, 0xFFFF00FF, "Feliz 2026! Você recebeu $20.260!");
        GivePlayerMoney(playerid, 20260);
    } else {
        SendClientMessage(playerid, -1, "O evento de Ano Novo já passou.");
    }
    return 1;
}
