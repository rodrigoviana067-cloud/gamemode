#if defined _a_samp_included
  #endinput
#endif
#define _a_samp_included
#define _samp_included

#define MAX_PLAYERS 1000
#define MAX_PLAYER_NAME 24

// Natives básicos
native print(const string[]);
native SetGameModeText(const string[]);
native SendClientMessage(playerid, color, const message[]);
native GetPlayerMoney(playerid);
native GivePlayerMoney(playerid, amount);
native GetPlayerPos(playerid, &Float:x, &Float:y, &Float:z);
native GetPlayerFacingAngle(playerid);
native PutPlayerInVehicle(playerid, vehicleid, seatid);
native CreateVehicle(modelid, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay);
native DestroyVehicle(vehicleid);
native CreatePickup(modelid, type, Float:x, Float:y, Float:z);
native Create3DTextLabel(const text[], color, Float:x, Float:y, Float:z, Float:drawdistance, virtualworld);
native GetMaxPlayers();
native str2num(const string[], &value);
