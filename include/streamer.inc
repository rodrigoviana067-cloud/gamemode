native CreateDynamicPickup(modelid, type, Float:x, Float:y, Float:z, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = 200.0);
native CreateDynamic3DTextLabel(const text[], color, Float:x, Float:y, Float:z, Float:drawdistance, playerid = INVALID_PLAYER_ID, vehicleid = INVALID_VEHICLE_ID, testlos = 0, worldid = -1, interiorid = -1, playerid2 = -1, Float:streamdistance = 200.0);
native SetDynamic3DTextLabelText(Text3D:id, color, const text[]);
native DestroyDynamic3DTextLabel(Text3D:id);
