#if defined _file_included
  #endinput
#endif
#define _file_included

native File:fopen(const filename[], const mode[]);
native fclose(File:handle);
native fread(File:handle, buffer[], size = sizeof buffer);
native fwrite(File:handle, const buffer[]);
native fseek(File:handle, position, seek = seek_start);
native ftell(File:handle);
native bool:feof(File:handle);
native bool:fexist(const filename[]);
native flength(File:handle);
native fremove(const filename[]);
native frename(const oldname[], const newname[]);
