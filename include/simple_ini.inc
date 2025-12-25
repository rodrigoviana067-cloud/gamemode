// ==============================
// Funções auxiliares (Pawn puro)
// ==============================

stock strcopy(dest[], size, const src[])
{
    new i;
    for (i = 0; i < size - 1 && src[i] != '\0'; i++)
        dest[i] = src[i];
    dest[i] = '\0';
    return i;
}

stock trim(string[])
{
    new len = strlen(string);

    // Remove espaços do final
    while (len > 0 &&
        (string[len - 1] == ' ' ||
         string[len - 1] == '\n' ||
         string[len - 1] == '\r' ||
         string[len - 1] == '\t'))
    {
        string[len - 1] = '\0';
        len--;
    }

    // Remove espaços do início
    new start = 0;
    while (string[start] == ' ' ||
           string[start] == '\n' ||
           string[start] == '\r' ||
           string[start] == '\t')
    {
        start++;
    }

    if (start > 0)
    {
        new i = 0;
        while (string[start + i] != '\0')
        {
            string[i] = string[start + i];
            i++;
        }
        string[i] = '\0';
    }

    return 1;
}


    new start = 0;
    while (string[start] == ' ' || string[start] == '\n' || string[start] == '\r' || string[start] == '\t')
        start++;

    if (start > 0)
        strcopy(string, len - start + 1, string[start]);

    return 1;
}

// simple_ini.inc - INI simples compatível Pawn 3.10.10 / SA-MP 0.3
// Sobrescreve valores existentes

stock bool:WriteINIString(const file[], const section[], const key[], const value[])
{
    new File:f;
    new text[8192]; // buffer de leitura
    new lines[512][128];
    new count = 0, i;
    new in_section = 0, found = 0;

    // Ler arquivo existente
    f = fopen(file, io_read);
    if (f)
    {
        new len;
        while ((len = fread(f, text, sizeof(text))) > 0)
        {
            new line[128], idx = 0, j;
            for (j = 0; j < len; j++)
            {
                if (text[j] == 10 || text[j] == 13) // LF ou CR
                {
                    line[idx] = '\0';
                    trim(line);
                    if (strlen(line)) strcopy(lines[count++], sizeof(lines[count-1]), line);
                    idx = 0;
                }
                else line[idx++] = text[j];
            }
        }
        fclose(f);
    }

    // Atualizar valor ou adicionar
    in_section = 0;
    found = 0;
    for (i = 0; i < count; i++)
    {
        if (lines[i][0] == '[')
        {
            in_section = strcmp(strmid(lines[i], 1, strlen(lines[i])-2), section) == 0;
            continue;
        }
        if (in_section)
        {
            new tmpkey[128], tmpval[128];
            if (sscanf(lines[i], "s=s", tmpkey, tmpval) == 2)
            {
                if (strcmp(tmpkey, key) == 0)
                {
                    format(lines[i], sizeof(lines[i]), "%s=%s", key, value);
                    found = 1;
                    break;
                }
            }
        }
    }

    if (!found)
    {
        format(lines[count++], sizeof(lines[count-1]), "[%s]", section);
        format(lines[count++], sizeof(lines[count-1]), "%s=%s", key, value);
    }

    // Reescrever arquivo
    f = fopen(file, io_write);
    if (!f) return false;

    for (i = 0; i < count; i++)
    {
        fwrite(f, lines[i], strlen(lines[i]));
        fwrite(f, "\r\n", 2);
    }
    fclose(f);
    return true;
}

stock bool:ReadINIString(const file[], const section[], const key[], const def[], dest[], size)
{
    new File:f = fopen(file, io_read);
    if (!f) { strcopy(dest, size, def); return false; }

    new text[8192];
    new lines[512][128];
    new count = 0, i, j;
    new len = fread(f, text, sizeof(text));
    fclose(f);

    new line[128], idx = 0;
    for (j = 0; j < len; j++)
    {
        if (text[j] == 10 || text[j] == 13)
        {
            line[idx] = '\0';
            trim(line);
            if (strlen(line)) strcopy(lines[count++], sizeof(lines[count-1]), line);
            idx = 0;
        }
        else line[idx++] = text[j];
    }

    new in_section = 0;
    for (i = 0; i < count; i++)
    {
        if (lines[i][0] == '[')
        {
            in_section = strcmp(strmid(lines[i], 1, strlen(lines[i])-2), section) == 0;
            continue;
        }
        if (in_section)
        {
            new tmpkey[128], tmpval[128];
            if (sscanf(lines[i], "s=s", tmpkey, tmpval) == 2)
            {
                if (strcmp(tmpkey, key) == 0)
                {
                    strcopy(dest, size, tmpval);
                    return true;
                }
            }
        }
    }

    strcopy(dest, size, def);
    return false;
}

stock WriteINIInt(const file[], const section[], const key[], value)
{
    new tmp[16]; format(tmp, sizeof(tmp), "%d", value);
    return WriteINIString(file, section, key, tmp);
}

stock ReadINIInt(const file[], const section[], const key[], def)
{
    new tmp[16];
    if (ReadINIString(file, section, key, "", tmp, sizeof(tmp)))
        return strval(tmp);
    return def;
}

stock WriteINIFloat(const file[], const section[], const key[], Float:value)
{
    new tmp[32]; format(tmp, sizeof(tmp), "%f", value);
    return WriteINIString(file, section, key, tmp);
}

stock Float:ReadINIFloat(const file[], const section[], const key[], Float:default)
{
    new tmp[32];
    if (ReadINIString(file, section, key, "", tmp, sizeof(tmp)))
        return strfloat(tmp);
    return default;
}
