// Adicione isso no OnFilterScriptInit para evitar erros de pasta faltando
public OnFilterScriptInit() {
    print(">> FS Casas 2026: Carregado.");
    // Tenta criar a pasta se não existir (apenas para Windows/alguns plugins)
    // No Linux, você deve criar a pasta 'houses' dentro de 'scriptfiles' manualmente.
    
    for(new i = 0; i < MAX_HOUSES; i++) {
        LoadHouse(i);
    }
    return 1;
}

// Remova o 'forward' e defina a função assim:
stock LoadHouse(id) {
    new file[64]; 
    HouseFile(id, file, sizeof file);
    if(!dini_Exists(file)) return 0;

    House[id][hX] = dini_Float(file, "X");
    House[id][hY] = dini_Float(file, "Y");
    House[id][hZ] = dini_Float(file, "Z");
    House[id][hIntX] = dini_Float(file, "IX");
    House[id][hIntY] = dini_Float(file, "IY");
    House[id][hIntZ] = dini_Float(file, "IZ");
    House[id][hInterior] = dini_Int(file, "Interior");
    
    // Correção no dini_Get (armazenar string corretamente)
    valstr(House[id][hOwner], 0); // Limpa
    format(House[id][hOwner], MAX_PLAYER_NAME, "%s", dini_Get(file, "Owner"));
    
    House[id][hLocked] = dini_Int(file, "Locked");

    // Limpeza de objetos antigos antes de recriar
    if(House[id][hLabel] != Text3D:0) {
        DestroyDynamic3DTextLabel(House[id][hLabel]);
        House[id][hLabel] = Text3D:0;
    }
    if(House[id][hPickup] != 0) {
        DestroyDynamicPickup(House[id][hPickup]);
        House[id][hPickup] = 0;
    }

    new str[150];
    if(!strcmp(House[id][hOwner], "Ninguem", true)) {
        format(str, sizeof str, "{00FF00}Casa à Venda\n{FFFFFF}ID: %d\nPreço: {00FF00}$%d\n{FFFFFF}/buyhouse", id, HOUSE_PRICE);
        House[id][hPickup] = CreateDynamicPickup(1273, 1, House[id][hX], House[id][hY], House[id][hZ]);
        House[id][hLabel] = CreateDynamic3DTextLabel(str, -1, House[id][hX], House[id][hY], House[id][hZ] + 0.8, 15.0);
    } else {
        format(str, sizeof str, "{00CCFF}Casa de: {FFFFFF}%s\n{00CCFF}Status: %s\n{FFFFFF}/enterhouse", House[id][hOwner], (House[id][hLocked] ? "{FF0000}Trancada" : "{00FF00}Aberta"));
        House[id][hPickup] = CreateDynamicPickup(1272, 1, House[id][hX], House[id][hY], House[id][hZ]);
        House[id][hLabel] = CreateDynamic3DTextLabel(str, -1, House[id][hX], House[id][hY], House[id][hZ] + 0.8, 15.0);
    }
    return 1;
}
