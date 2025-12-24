#if defined _samp_included
  #endinput
#endif
#define _samp_included

#pragma library samp
#pragma tabsize 4
#include <core>
#include <float>
#include <string>
#include <file>
#include <time>
#include <datagram>
#include <a_players>
#include <a_vehicles>
#include <a_objects>
#include <a_sampdb>

// Player
native SetTeamCount(count);
native GetPlayerName(playerid, name[], len);
native IsPlayerConnected(playerid);
native IsPlayerNPC(playerid);
native GetPlayerMoney(playerid);
native GivePlayerMoney(playerid, amount);
native GetPlayerPos(playerid, &Float:x, &Float:y, &Float:z);
native PutPlayerInVehicle(playerid, vehicleid, seatid);
native GetPlayerFacingAngle(playerid);

// Game
native SetGameModeText(const string[]);
native SetMaxPlayers(count);
native AddPlayerClass(modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle,
                      weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo);
native SetTeamCount(count);
native CreateExplosion(Float:X, Float:Y, Float:Z, type, Float:Radius);
native SetWorldTime(hour);
native SetWeather(weatherid);
native SetGravity(Float:gravity);
native GameModeExit();
native SendClientMessage(playerid, color, const message[]);
native SendClientMessageToAll(color, const message[]);

// Functions
native strlen(const string[]);
native strval(const value[], buffer[], len);
native CallLocalFunction(const func[], const format[], {Float,_}:...);
native CallRemoteFunction(const func[], const format[], {Float,_}:...);
native tolower(c);
