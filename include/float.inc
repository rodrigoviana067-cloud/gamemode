#if defined _float_included
  #endinput
#endif
#define _float_included

native Float:floatmul(Float:oper1, Float:oper2);
native Float:floatdiv(Float:oper1, Float:oper2);
native Float:floatadd(Float:oper1, Float:oper2);
native Float:floatsub(Float:oper1, Float:oper2);
native Float:floatfract(Float:value);
native Float:floatround(Float:value, rounding = floatround_round);
native Float:floatcmp(Float:oper1, Float:oper2);
native Float:floatabs(Float:value);
