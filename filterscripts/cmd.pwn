#include <a_samp>
#include <YSF>
#include <zcmd>
#include <dini>
#include <streamer>

#define MAX_PLAYERS 500
#define MAX_HOUSES 100

new PlayerLogged[MAX_PLAYERS];
new PlayerHouse[MAX_PLAYERS]; // Armazena ID da casa que o player está
new HouseOwner[MAX_HOUSES];   // Armazena playerid que possui a casa
new HousePosX[MAX_HOUSES];
new HousePosY[MAX_HOUSES];
new HousePosZ[MAX_HOUSES];
new HouseInterior[MAX_HOUSES];
new HousePrice[MAX_HOUSES];
new Text3D:HouseLabel[MAX_HOUSES];
new Pickup:HousePickup[MAX_HOUSES];

#define HOUSES_FILE "houses.ini"
#define PLAYERS_FILE "players.ini"

// ==================================================
// Inicialização
// ==================================================
public OnFilterScriptInit()
{
    // Carregar casas
    for(new i = 0; i < MAX_HOUSES; i++)
    {
        HouseOwner[i] = dini_Int(HOUSES_FILE, format("house_owner_%d", i));
        HousePosX[i] = dini_Float(HOUSES_FILE, format("house_x_%d", i));
        HousePosY[i] = dini_Float(HOUSES_FILE, format("house_y_%d", i));
        HousePosZ[i] = dini_Float(HOUSES_FILE, format("house_z_%d", i));
        HouseInterior[i] = dini_Int(HOUSES_FILE, format("house_interior_%d", i));
        HousePrice[i] = dini_Int(HOUSES_FILE, format("house_price_%d", i));

        if(HouseOwner[i] != -1)
        {
            // Criar Pickup e 3DTextLabel
            HousePickup[i] = CreateDynamicPickup(1272, 1, HousePosX[i], HousePosY[i], HousePosZ[i], -1, HouseInterior[i]);
            HouseLabel[i] = CreateDynamic3DTextLabel(
                "Casa disponível",
                0xFFFFFFFF,
                HousePosX[i], HousePosY[i], HousePosZ[i] + 1.0,
                20.0,
                INVALID_PLAYER_ID,
                -1,
                0,
                -1,
                HouseInterior[i]
            );
        }
    }
    return 1;
}

// ==================================================
// Login
// ==================================================
CMD:register(playerid, params[])
{
    new senha[64];
    sscanf(params, "s", senha);

    if(PlayerLogged[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "Você já está logado.");
        return 1;
    }

    if(!dini_Isset(PLAYERS_FILE, format("player_%d_password", playerid)))
    {
        // Registro
        dini_Set(PLAYERS_FILE, format("player_%d_password", playerid), senha);
        PlayerLogged[playerid] = 1;
        SendClientMessage(playerid, 0x00FF00FF, "Registrado e logado com sucesso!");
    }
    else
    {
        // Login
        if(!strcmp(dini_Get(PLAYERS_FILE, format("player_%d_password", playerid)), senha, true))
        {
            PlayerLogged[playerid] = 1;
            SendClientMessage(playerid, 0x00FF00FF, "Logado com sucesso!");
        }
        else
        {
            SendClientMessage(playerid, 0xFF0000FF, "Senha incorreta!");
        }
    }
    return 1;
}

// ==================================================
// Comandos de Casa
// ==================================================
CMD:buyhouse(playerid, params[])
{
    if(!PlayerLogged[playerid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "Você precisa estar logado para comprar casa.");
        return 1;
    }

    new houseid;
    sscanf(params, "i", houseid);

    if(HouseOwner[houseid] != -1)
    {
        SendClientMessage(playerid, 0xFF0000FF, "Esta casa já está vendida.");
        return 1;
    }

    // Dinheiro do player (simulado)
    new playerMoney = 5000; // Aqui você pode integrar com seu sistema de dinheiro
    if(playerMoney < HousePrice[houseid])
    {
        SendClientMessage(playerid, 0xFF0000FF, "Você não tem dinheiro suficiente.");
        return 1;
    }

    // Compra
    HouseOwner[houseid] = playerid;
    PlayerHouse[playerid] = houseid;

    dini_IntSet(HOUSES_FILE, format("house_owner_%d", houseid), playerid);

    // Atualizar 3DTextLabel e Pickup
    SetDynamic3DTextLabelText(HouseLabel[houseid], 0xFF00FFFF, "Casa vendida");

    SendClientMessage(playerid, 0x00FF00FF, "Você comprou a casa com sucesso!");
    return 1;
}

CMD:enterhouse(playerid, params[])
{
    new houseid = PlayerHouse[playerid];
    if(houseid == -1)
    {
        SendClientMessage(playerid, 0xFF0000FF, "Você não possui nenhuma casa.");
        return 1;
    }

    SetPlayerInterior(playerid, HouseInterior[houseid]);
    SetPlayerPos(playerid, HousePosX[houseid], HousePosY[houseid], HousePosZ[houseid]);
    SendClientMessage(playerid, 0x00FF00FF, "Você entrou em sua casa.");
    return 1;
}

CMD:sellhouse(playerid, params[])
{
    new houseid = PlayerHouse[playerid];
    if(houseid == -1)
    {
        SendClientMessage(playerid, 0xFF0000FF, "Você não possui casa para vender.");
        return 1;
    }

    HouseOwner[houseid] = -1;
    PlayerHouse[playerid] = -1;
    dini_IntSet(HOUSES_FILE, format("house_owner_%d", houseid), -1);

    SetDynamic3DTextLabelText(HouseLabel[houseid], 0xFFFFFFFF, "Casa disponível");
    SendClientMessage(playerid, 0x00FF00FF, "Você vendeu a casa com sucesso!");
    return 1;
}
