#if defined _a_samp_included
  #endinput
#endif
#define _a_samp_included
#define _samp_included

// =====================================================
// DEFINIÇÕES BÁSICAS
// =====================================================
#define MAX_PLAYERS 1000
#define MAX_PLAYER_NAME 24
#define MAX_PLAYERS 1000

// =====================================================
// NATIVES BÁSICOS DO SERVIDOR
// =====================================================
native print(const string[]);
native SetGameModeText(const string[]);
native SendClientMessage(playerid, color, const message[]);

// =====================================================
// NATIVES DO PLAYER
// =====================================================
native GetPlayerMoney(playerid);
native GivePlayerMoney(playerid, amount);
native GetPlayerPos(playerid, &Float:x, &Float:y, &Float:z);
native GetPlayerFacingAngle(playerid);
native PutPlayerInVehicle(playerid, vehicleid, seatid);

// =====================================================
// NATIVES DE VEÍCULO
// =====================================================
native CreateVehicle(modelid, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay);
native DestroyVehicle(vehicleid);

// =====================================================
// NATIVES DE PICKUP / TEXTLABEL
// =====================================================
native CreatePickup(modelid, type, Float:x, Float:y, Float:z);
native Create3DTextLabel(const text[], color, Float:x, Float:y, Float:z, Float:drawdistance, virtualworld);

// =====================================================
// NATIVES GLOBAIS ADICIONAIS (Opcional)
// =====================================================
native GetMaxPlayers();

// =====================================================
// OBSERVAÇÃO
// =====================================================
// Este include é compatível com SA-MP 0.3 + ZCMD + sscanf2
// Ele não depende de includes externos ou tipos modernos
