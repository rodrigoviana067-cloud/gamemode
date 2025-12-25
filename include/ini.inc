// ini.inc - versão simples
// Funções básicas para ler e escrever INI (arquivos simples)

stock bool:INI_WriteString(const file[], const section[], const key[], const value[])
{
    new File:f;
    f = fopen(file, io_append);
    if (!f) return false;
    fprintf(f, "[%s]\n%s=%s\n", section, key, value);
    fclose(f);
    return true;
}

stock INI_ReadString(const file[], const section[], const key[], const default[], dest[], size)
{
    new File:f;
    new linha[128], in_section = 0;

    strcopy(dest, size, default);

    f = fopen(file, io_read);
    if (!f) return false;

    while (fgets(f, linha, sizeof(linha)))
    {
        trim(linha);
        if (strlen(linha) == 0) continue;

        if (linha[0] == '[')
        {
            in_section = strmid(linha, 1, strlen(linha)-2) == section;
            continue;
        }

        if (in_section)
        {
            new tmp[128];
            if (sscanf(linha, "s=s", tmp, dest) == 2)
            {
                fclose(f);
                return true;
            }
        }
    }

    fclose(f);
    return false;
}

stock INI_WriteInt(const file[], const section[], const key[], value)
{
    new val[16];
    format(val, sizeof(val), "%d", value);
    return INI_WriteString(file, section, key, val);
}

stock INI_ReadInt(const file[], const section[], const key[], default)
{
    new val[16], result;
    if (INI_ReadString(file, section, key, "", val, sizeof(val)))
    {
        return strval(val);
    }
    return default;
}

stock INI_WriteFloat(const file[], const section[], const key[], Float:value)
{
    new val[32];
    format(val, sizeof(val), "%f", value);
    return INI_WriteString(file, section, key, val);
}

stock Float:INI_ReadFloat(const file[], const section[], const key[], Float:default)
{
    new val[32];
    if (INI_ReadString(file, section, key, "", val, sizeof(val)))
    {
        return strfloat(val);
    }
    return default;
}
