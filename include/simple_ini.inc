// include/simple_ini.inc
stock bool:WriteINIString(const file[], const section[], const key[], const value[])
{
    new File:f = fopen(file, io_append);
    if (!f) return false;
    fprintf(f, "[%s]\n%s=%s\n", section, key, value);
    fclose(f);
    return true;
}

stock bool:ReadINIString(const file[], const section[], const key[], const def[], dest[], size)
{
    new File:f = fopen(file, io_read);
    if (!f) { strcopy(dest, size, def); return false; }

    new line[128], in_section = 0;
    while (!feof(f))
    {
        fgets(f, line, sizeof(line));
        trim(line);
        if (strlen(line) == 0) continue;
        if (line[0] == '[') { in_section = strcmp(strmid(line, 1, strlen(line)-2), section) == 0; continue; }
        if (in_section)
        {
            new tmp[128];
            if (sscanf(line, "s=s", tmp, dest) == 2) { fclose(f); return true; }
        }
    }
    fclose(f);
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
