#define FILTERSCRIPT
#include <a_samp>
#include <dini>

// Preços por Categoria (Economia 2026)
#define PRECO_MOTO      3000
#define PRECO_CARRO     7000
#define PRECO_CAMINHAO  15000

// Veículos de Teste
#define VEH_MOTO        461 // PCJ-600
#define VEH_CARRO       405 // Sentinel
#define VEH_CAMINHAO    403 // Linerunner

#define LOCAL_AUTO      1215.0, -1812.0, 13.5
#define DIALOG_AUTO     9955

new EmTeste[MAX_PLAYERS];
new VeiculoTeste[MAX_PLAYERS];
new CategoriaTeste[MAX_PLAYERS]; // 1: Moto, 2: Carro, 3: Caminhão
new CheckStep[MAX_PLAYERS];

stock CNHFile(playerid) {
    new name[MAX_PLAYER_NAME], str[64];
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), "licencas/%s.ini", name);
    return str;
}

public OnFilterScriptInit() {
    CreatePickup(1239, 1, LOCAL_AUTO, -1);
    Create3DTextLabel("{FFFFFF}Autoescola LS\n{FFFF00}Use /exame", -1, LOCAL_AUTO, 10.0, 0);
    print(">> [AUTOESCOLA 2026] Categorias Carro/Moto/Caminhao prontas.");
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(!strcmp(cmdtext, "/exame", true)) {
        if(!IsPlayerInRangeOfPoint(playerid, 3.0, LOCAL_AUTO)) return SendClientMessage(playerid, -1, "{FF0000}Vá até a Autoescola!");
        
        ShowPlayerDialog(playerid, DIALOG_AUTO, DIALOG_STYLE_LIST, "{00CCFF}Autoescola - Categorias", 
            "Categoria A (Moto) - $3.000\nCategoria B (Carro) - $7.000\nCategoria C (Caminhão) - $15.000", "Escolher", "Sair");
        return 1;
    }
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == DIALOG_AUTO && response) {
        new preco, veh;
        switch(listitem) {
            case 0: { preco = PRECO_MOTO; veh = VEH_MOTO; CategoriaTeste[playerid] = 1; }
            case 1: { preco = PRECO_CARRO; veh = VEH_CARRO; CategoriaTeste[playerid] = 2; }
            case 2: { preco = PRECO_CAMINHAO; veh = VEH_CAMINHAO; CategoriaTeste[playerid] = 3; }
        }

        if(GetPlayerMoney(playerid) < preco) return SendClientMessage(playerid, -1, "{FF0000}Dinheiro insuficiente!");
        
        GivePlayerMoney(playerid, -preco);
        EmTeste[playerid] = 1;
        CheckStep[playerid] = 0;
        VeiculoTeste[playerid] = CreateVehicle(veh, 1210.0, -1820.0, 13.5, 180.0, 1, 1, 120);
        PutPlayerInVehicle(playerid, VeiculoTeste[playerid], 0);
        
        SetPlayerCheckpoint(playerid, 1245.0, -1850.0, 13.5, 5.0);
        SendClientMessage(playerid, 0xFFFF00FF, "[AUTOESCOLA] Teste iniciado! Não saia e não destrua o veículo.");
    }
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    if(EmTeste[playerid]) {
        CheckStep[playerid]++;
        switch(CheckStep[playerid]) {
            case 1: SetPlayerCheckpoint(playerid, 1300.0, -1850.0, 13.5, 5.0);
            case 2: SetPlayerCheckpoint(playerid, 1215.0, -1815.0, 13.5, 5.0);
            case 3: FinalizarTeste(playerid, true);
        }
    }
    return 1;
}

stock FinalizarTeste(playerid, bool:aprovado) {
    DisablePlayerCheckpoint(playerid);
    DestroyVehicle(VeiculoTeste[playerid]);
    EmTeste[playerid] = 0;

    if(aprovado) {
        new file[64]; format(file, 64, "%s", CNHFile(playerid));
        if(!dini_Exists(file)) dini_Create(file);
        
        if(CategoriaTeste[playerid] == 1) dini_IntSet(file, "Moto", 1);
        else if(CategoriaTeste[playerid] == 2) dini_IntSet(file, "Carro", 1);
        else if(CategoriaTeste[playerid] == 3) dini_IntSet(file, "Caminhao", 1);
        
        SendClientMessage(playerid, 0x00FF00FF, "[AUTOESCOLA] Aprovado! Licença emitida.");
    } else {
        SendClientMessage(playerid, 0xFF0000FF, "[AUTOESCOLA] Você falhou no teste.");
    }
    return 1;
}
