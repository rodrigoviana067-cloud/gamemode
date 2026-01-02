if(!strfind(cmdtext, "/carro", true)) {
    new vID, c1, c2;
    if(sscanf_fix(cmdtext, vID, c1, c2)) {
        if(sscanf_fix(cmdtext, vID)) return SendClientMessage(playerid, -1, "Use: /carro [ID] [Cor1] [Cor2]");
        c1 = 1; c2 = 1;
    }

    if(vID < 400 || vID > 611) return SendClientMessage(playerid, -1, "ID Invalido.");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z); 
    GetPlayerFacingAngle(playerid, a);

    // Criamos o veículo 2 metros ACIMA do chão (Z + 2.0)
    // Isso faz com que o carro caia reto e resete a suspensão.
    new v = CreateVehicle(vID, x, y, z + 2.0, a, c1, c2, -1);
    
    // Linkamos o veículo ao mundo virtual e interior do player para evitar desync
    SetVehicleVirtualWorld(v, GetPlayerVirtualWorld(playerid));
    SetVehicleInterior(v, GetPlayerInterior(playerid));

    // Coloca o jogador no banco do motorista
    PutPlayerInVehicle(playerid, v, 0);
    
    SendClientMessage(playerid, 0x00FF00FF, "Veiculo criado! (Fisica estabilizada)");
    return 1;
}
