CMD:carro(playerid, params[]) {
    if(!IsPlayerAdmin(playerid) && GetPVarInt(playerid, "AdminLevel") < 6) 
        return SendClientMessage(playerid, 0xFF0000FF, "Erro: Você não é Admin Master.");

    new modelid, cor1, cor2;
    // Tenta ler os parâmetros manualmente sem sscanf
    if(unformat(params, "ddd", modelid, cor1, cor2)) {
        // Se falhar o unformat/sscanf, usamos valores padrão para testar
        if(unformat(params, "d", modelid)) { 
            return SendClientMessage(playerid, -1, "Use: /carro [ID] [Cor1] [Cor2]");
        }
        cor1 = 1; cor2 = 1; // Se você digitar só /carro 411, ele criará branco
    }

    if(modelid < 400 || modelid > 611) return SendClientMessage(playerid, -1, "ID de 400 a 611.");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    
    new veh = CreateVehicle(modelid, x, y, z + 1.0, a, cor1, cor2, -1);
    PutPlayerInVehicle(playerid, veh, 0);
    
    SendClientMessage(playerid, 0x00FF00FF, "Veículo criado!");
    return 1;
}
