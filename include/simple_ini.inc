// include/simple_ini.inc - INI simples com sobrescrita
stock bool:WriteINIString(const file[], const section[], const key[], const value[])
{
    new File:f;
    new lines[1024][128]; // buffer temporário
    new count = 0;
    new in_section = 0, found = 0;
    new i;

    // Ler arquivo se existir
    f = fopen(file, io_read);
    if (f)
    {
        while (!feof(f))
        {
            fgets(f, lines[count], sizeof(lines[count]));
            trim(lines[count]);
            count++;
            if (count >= sizeof(lines)) break;
        }
        fclose(f);
    }

    // Atualizar ou adicionar valor
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
            new tmp[128];
            if (sscanf(lines[i], "s=s", tmp, tmp) == 2)
            {
                if (strcmp(tmp, key) == 0)
                {
                    format(lines[i], sizeof(lines[i]), "%s=%s", key, value);
                    found = 1;
                    break;
                }
            }
        }
    }

    // Se não encontrou, adiciona seção/chave
    if (!found)
    {
        if (!count || strcmp(strmid(lines[count-1], 0, 1), "[") != 0) // não adiciona seção duplicada
            format(lines[count++], sizeof(lines[count-1]), "[%s]", section);
        format(lines[count++], sizeof(lines[count-1]), "%s=%s", key, value);
    }

    // Reescrever arquivo
    f = fopen(file, io_write);
    if (!f) return false;

    for (i = 0; i < count; i++)
    {
        fprintf(f, "%s\r\n", lines[i]);
    }
    fclose(f);
    return true;
}

stock bool:ReadINIString(const file[], const section[], const key[], const def[], dest[], size)
{
    new File:f = fopen(file, io_read);
    if (!f) { strcopy(dest, size, def); return false; }

    new line[128];
    new in_section = 0;
    while (!feof(f))
    {
        fgets(f, line, sizeof(line));
        trim(line);
        if (strlen(line) == 0) continue;
        if (line[0] == '[')
        {
            in_section = strcmp(strmid(line,1,strlen(line)-2), section) == 0;
            continue;
        }
        if (in_section)
        {
            new tmp[128];
            if (sscanf(line,"s=s", tmp, dest) == 2)
            {
                fclose(f);
                return true;
            }
        }
    }

    fclose(f);
    strcopy(dest, size, def);
    return false;
}

stock WriteINIInt(const file[], const section[], const key[], value)
{
    new tmp[16];
    format(tmp, sizeof(tmp), "%d", value);
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
