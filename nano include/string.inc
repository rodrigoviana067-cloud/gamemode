#if defined _string_included
  #endinput
#endif
#define _string_included

native strlen(const string[]);
native strcpy(dest[], const source[]);
native strcat(dest[], const source[]);
native strcmp(const string1[], const string2[], bool:ignorecase = false);
native strncmp(const string1[], const string2[], length, bool:ignorecase = false);
native strfind(const string[], const sub[], bool:ignorecase = false, pos = 0);
native strdel(string[], start, end);
native strins(string[], const substr[], pos);
native strmid(dest[], const source[], start, end, maxlength = sizeof dest);
native strpack(dest[], const source[], maxlength = sizeof dest);
native strunpack(dest[], const source[], maxlength = sizeof dest);
native tolower(character);
native toupper(character);
native isupper(character);
native islower(character);
native isdigit(character);
native isalpha(character);
native isalnum(character);
