/*
 *            Dini 1.6 (corrigido para Pawn moderno)
 *       (c) Copyright 2006-2008 by DracoBlue
 */

#if defined _dini_included
  #endinput
#endif

#define _dini_included

#include <file>
#include <float>
#include <string>

#if defined MAX_STRING
#define DINI_MAX_STRING MAX_STRING
#else
#define DINI_MAX_STRING 255
#endif

stock dini_Exists(const filename[]) {
    return fexist(filename);
}

stock dini_Remove(const filename[]) {
    return fremove(filename);
}

stock dini_Create(const filename[]) {
    if (fexist(filename)) return false;
    new File:fhnd = fopen(filename, io_write);
    if (fhnd) {
        fclose(fhnd);
        return true;
    }
    return false;
}

stock dini_Set(const filename[], const key[], const value[]) {
    new key_length = strlen(key);
    new value_length = strlen(value);
    if (key_length==0 || key_length+value_length+2>DINI_MAX_STRING) return false;

    new File:fohnd, File:fwhnd;
    new tmpres[DINI_MAX_STRING];
    new bool:wasset=false;

    format(tmpres, sizeof(tmpres), "%s.part", filename);
    fremove(tmpres);

    fohnd = fopen(filename, io_read);
    if (!fohnd) return false;

    fwhnd = fopen(tmpres, io_write);
    if (!fwhnd) {
        fclose(fohnd);
        return false;
    }

    while (fread(fohnd, tmpres)) {
        if (!wasset && tmpres[key_length]=='=' && !strcmp(tmpres, key, true, key_length)) {
            format(tmpres, sizeof(tmpres), "%s=%s", key, value);
            wasset = true;
        } else {
            DINI_StripNewLine(tmpres);
        }
        fwrite(fwhnd, tmpres);
        fwrite(fwhnd, "\r\n");
    }

    if (!wasset) {
        format(tmpres, sizeof(tmpres), "%s=%s", key, value);
        fwrite(fwhnd, tmpres);
        fwrite(fwhnd, "\r\n");
    }

    fclose(fohnd);
    fclose(fwhnd);

    format(tmpres, sizeof(tmpres), "%s.part", filename);
    if (DINI_fcopytextfile(tmpres, filename)) {
        return fremove(tmpres);
    }
    return false;
}

stock dini_IntSet(const filename[], const key[], value) {
    new valuestring[DINI_MAX_STRING];
    format(valuestring, sizeof(valuestring), "%d", value);
    return dini_Set(filename, key, valuestring);
}

stock dini_Int(const filename[], const key[]) {
    return strval(dini_Get(filename, key));
}

stock dini_FloatSet(const filename[], const key[], Float:value) {
    new valuestring[DINI_MAX_STRING];
    format(valuestring, sizeof(valuestring), "%f", value);
    return dini_Set(filename, key, valuestring);
}

stock Float:dini_Float(const filename[], const key[]) {
    return floatstr(dini_Get(filename, key));
}

stock dini_Bool(const filename[], const key[]) {
    return strval(dini_Get(filename, key));
}

stock dini_BoolSet(const filename[], const key[], value) {
    return dini_Set(filename, key, value ? "1" : "0");
}

stock dini_Unset(const filename[], const key[]) {
    new key_length = strlen(key);
    if (key_length==0 || key_length+2>DINI_MAX_STRING) return false;

    new File:fohnd, File:fwhnd;
    new tmpres[DINI_MAX_STRING];

    format(tmpres, sizeof(tmpres), "%s.part", filename);
    fremove(tmpres);

    fohnd = fopen(filename, io_read);
    if (!fohnd) return false;

    fwhnd = fopen(tmpres, io_write);
    if (!fwhnd) {
        fclose(fohnd);
        return false;
    }

    while (fread(fohnd, tmpres)) {
        if (!(tmpres[key_length]=='=' && !strcmp(tmpres, key, true, key_length))) {
            DINI_StripNewLine(tmpres);
            fwrite(fwhnd, tmpres);
            fwrite(fwhnd, "\r\n");
        }
    }

    fclose(fohnd);
    fclose(fwhnd);

    format(tmpres, sizeof(tmpres), "%s.part", filename);
    if (DINI_fcopytextfile(tmpres, filename)) {
        return fremove(tmpres);
    }
    return false;
}

stock dini_Get(const filename[], const key[]) {
    new tmpres[DINI_MAX_STRING];
    new key_length = strlen(key);
    if (key_length==0 || key_length+2>DINI_MAX_STRING) return tmpres;

    new File:fohnd = fopen(filename, io_read);
    if (!fohnd) return tmpres;

    while (fread(fohnd, tmpres)) {
        if (tmpres[key_length]=='=' && !strcmp(tmpres, key, true, key_length)) {
            DINI_StripNewLine(tmpres);
            strmid(tmpres, tmpres, key_length+1, strlen(tmpres), DINI_MAX_STRING);
            fclose(fohnd);
            return tmpres;
        }
    }
    fclose(fohnd);
    return tmpres;
}

stock dini_Isset(const filename[], const key[]) {
    new key_length = strlen(key);
    if (key_length==0 || key_length+2>DINI_MAX_STRING) return false;

    new File:fohnd = fopen(filename, io_read);
    if (!fohnd) return false;

    new tmpres[DINI_MAX_STRING];
    while (fread(fohnd, tmpres)) {
        if (tmpres[key_length]=='=' && !strcmp(tmpres, key, true, key_length)) {
            fclose(fohnd);
            return true;
        }
    }
    fclose(fohnd);
    return false;
}

stock DINI_StripNewLine(string[]) {
    new len = strlen(string);
    if (len==0) return;
    if ((string[len-1]=='\n') || (string[len-1]=='\r')) string[len-1]=0;
    len = strlen(string);
    if (len>0 && ((string[len-1]=='\n') || (string[len-1]=='\r'))) string[len-1]=0;
}

stock DINI_fcopytextfile(const oldname[], const newname[]) {
    new File:ohnd, File:nhnd;
    if (!fexist(oldname)) return false;
    ohnd=fopen(oldname, io_read);
    if (!ohnd) return false;
    nhnd=fopen(newname, io_write);
    if (!nhnd) { fclose(ohnd); return false; }

    new tmpres[DINI_MAX_STRING];
    while (fread(ohnd, tmpres)) {
        DINI_StripNewLine(tmpres);
        format(tmpres, sizeof(tmpres), "%s\r\n", tmpres);
        fwrite(nhnd, tmpres);
    }
    fclose(ohnd);
    fclose(nhnd);
    return true;
}
