#if defined _time_included
  #endinput
#endif
#define _time_included

native gettime(&hour, &minute, &second);
native getdate(&year, &month, &day);
native tickcount();
