#if defined _streamer_included
    #endinput
#endif
#define _streamer_included

#define INVALID_PLAYER_ID (-1)
#define INVALID_STREAMER_ID (-1)

typedef Text3D;
typedef Pickup;

native CreateDynamicPickup(modelid, type, Float:x, Float:y, Float:z, worldid = -1, interiorid = -1, playerid = INVALID_PLAYER_ID, Float:streamdistance = 200.0);
native CreateDynamic3DTextLabel(const text[], color, Float:x, Float:y, Float:z, Float:drawdistance, playerid = INVALID_PLAYER_ID, vehicleid = -1, testlos = 0, worldid = -1, interiorid = -1, playerid2 = -1, Float:streamdistance = 200.0);
native SetDynamic3DTextLabelText(Text3D:id, color, const text[]);
native DestroyDynamic3DTextLabel(Text3D:id);
