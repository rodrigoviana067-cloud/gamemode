#include <open.mp>
#include <YSI_Storage\y_ini>

// Dados que queremos salvar
enum pInfo {
    pDinheiro,
    pSkin,
    pPosicaoX,
    pPosicaoY,
    pPosicaoZ
}
new PlayerData[MAX_PLAYERS][pInfo];

// Função para carregar os dados do arquivo
forward LoadUser_Data(playerid, name[], value[]);
public LoadUser_Data(playerid, name[], value[]) {
    INI_Int("Dinheiro", PlayerData[playerid][pDinheiro]);
    INI_Int("Skin", PlayerData[playerid][pSkin]);
    INI_Float("PosX", PlayerData[playerid][pPosicaoX]);
    INI_Float("PosY", PlayerData[playerid][pPosicaoY]);
    INI_Float("PosZ", PlayerData[playerid][pPosicaoZ]);
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    new name[MAX_PLAYER_NAME], path[64];
    GetPlayerName(playerid, name, sizeof(name));
    format(path, sizeof(path), "/contas/%s.ini", name);

    if(fexist(path)) {
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        
        new INI:file = INI_Open(path);
        INI_WriteInt(file, "Dinheiro", GetPlayerMoney(playerid));
        INI_WriteInt(file, "Skin", GetPlayerSkin(playerid));
        INI_WriteFloat(file, "PosX", x);
        INI_WriteFloat(file, "PosY", y);
        INI_WriteFloat(file, "PosZ", z);
        INI_Close(file);
    }
    return 1;
}
