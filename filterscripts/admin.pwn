CMD:carro(playerid, params[]) {
    if(!IsPlayerAdmin(playerid) && GetPVarInt(playerid, "AdminLevel") < 6) 
        return SendClientMessage(playerid, 0xFF0000FF, "Erro: Você não é Admin Master.");

    if(isnull(params)) 
        return SendClientMessage(playerid, -1, "Use: /carro [ID] [Cor1] [Cor2]");

    new modelid, cor1, cor2;
    new pos;

    // Lendo o ModelID manualmente
    modelid = strval(params);
    
    // Procurando o próximo espaço para as cores
    pos = strfind(params, " ", true);
    if(pos == -1) {
        // Se você digitar apenas /carro 411
        cor1 = 1; cor2 = 1;
    } else {
        // Se houver mais números, lê as cores
        cor1 = strval(params[pos+1]);
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
    
    new msg[64];
    format(msg, sizeof(msg), "Veículo ID %d criado (Cores %d, %d)!", modelid, cor1, cor2);
    SendClientMessage(playerid, 0x00FF00FF, msg);
    return 1;
}
