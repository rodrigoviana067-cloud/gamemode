    // Comando de Carro - Versão Estabilizada com Spawn à Frente
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

        // CÁLCULO PARA CRIAR O CARRO 3 METROS À FRENTE DO JOGADOR
        // Isso evita que o corpo do player "empurre" o carro para o lado no spawn
        new Float:fX = pX + (3.0 * floatsin(-pA, degrees));
        new Float:fY = pY + (3.0 * floatcos(-pA, degrees));

        // Criamos o carro um pouco mais alto e à frente
        new v = CreateVehicle(vID, fX, fY, pZ + 2.0, pA, c1, c2, -1);
        
        // RESET TOTAL DE MOVIMENTO
        SetVehicleVelocity(v, 0.0, 0.0, 0.0);
        SetVehicleAngularVelocity(v, 0.0, 0.0, 0.0);
        
        // Força o ângulo do veículo a ser exatamente o que foi definido
        SetVehicleZAngle(v, pA); 

        SetVehicleVirtualWorld(v, GetPlayerVirtualWorld(playerid));
        LinkVehicleToInterior(v, GetPlayerInterior(playerid));
        
        PutPlayerInVehicle(playerid, v, 0);
        
        SendClientMessage(playerid, 0x00FF00FF, "Veiculo criado a frente com fisica resetada!");
        return 1;
    }
