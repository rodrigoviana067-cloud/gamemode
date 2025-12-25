#if defined _fileio_included
    #endinput
#endif
#define _fileio_included

native File: fopen(const name[], filemode: mode = io_read);
native fclose(File: handle);
native fwrite(File: handle, const string[]);
native fread(File: handle, string[], size = sizeof string);
native fexist(const name[]);
