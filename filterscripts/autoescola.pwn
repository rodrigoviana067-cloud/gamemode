#include <a_samp>
#include <dini>
 
#definir FILTERSCRIPT
#se definido FILTERSCRIPT
 
enum pInfo {
    Carteira
} ;
novo pDados [ MAX_PLAYERS ] [ pInfo ] ;
 
#define DIALOG_AUTOESCOLA 2
 
novo InAutoEscola [ MAX_JOGADORES ] ;
novo carroauto [ MAX_JOGADORES ] ;
novo CPAutoEscola;
 
novo ponto [ MAX_PLAYERS ] ;
novo Float : AutoPoints [ 8 ] [ 3 ]  =
{
     { 566.0122 , - 1240.4834 , 16.9812 } ,
     { 647.4115 , - 1202.2354 , 17.8508 } ,
     { 794.5209 , - 1061.8385 , 24.4309 } ,
     { 797.8555 , - 1255.2906 , 13.2295 } ,
     { 782.1776 , - 1318.7532 , 13.1247 } ,
     { 632.7460 , - 1290.5117 , 15.1381 } ,
     { 595.6362 , - 1228.1689 , 17.5915 } ,
     { 561.3011 , - 1279.6729 , 16.9883 }
} ;
 
público OnFilterScriptInit ( )
{
    CPAutoEscola = CPS_AddCheckpoint ( 545.2621 , - 1284.9412 , 17.2482 , 2.0 , 80 ) ;
    retornar  1 ;
}
 
público OnFilterScriptExit ( )
{
    retornar  1 ;
}
 
 
principal ( )
{
    imprimir ( " \n ----------------------------------" ) ;
    print ( "Sistema de Auto Escola" ) ;
    print ( "Visite: www.sampknd.com" ) ;
    imprimir ( "---------------------------------- \n " ) ;
}
 
público OnPlayerDeath ( playerid, killerid, reason )
{
    if ( InAutoEscola [ playerid ]  ==  1 )
    {
        novo veículo atual;
        currentveh =  GetPlayerVehicleID ( playerid ) ;
        DestruirVeículo ( veículoatual ) ;
        InAutoEscola [ playerid ]  =  0 ;
        DisablePlayerRaceCheckpoint ( playerid ) ;
    }
    retornar  1 ;
}
 
público OnPlayerEnterCheckpoint ( playerid )
{
    se ( CPS_IsPlayerInCheckpoint ( playerid,CPAutoEscola ) )
    {
        if ( pDados [ playerid ] [ Carteira ]  ==  0 )
        {
            ShowPlayerDialog ( playerid,DIALOG_AUTOESCOLA,DIALOG_STYLE_MSGBOX, "AUTO ESCOLA" , "Você gostaria de começar os testes da Auto Escola?" , "Sim" , "Nao" ) ;
            retornar  1 ;
        } else  return  SendClientMessage ( playerid, - 1 , "(AUTO ESCOLA) Você já possui Carteira." ) ;
    }
    retornar  1 ;
}
 
público OnPlayerEnterRaceCheckpoint ( playerid )
{
    alternar ( ponto [ playerid ] )
     {
         caso  1 :
         {
              DisablePlayerRaceCheckpoint ( playerid ) ;
              SetPlayerRaceCheckpoint ( playerid, 0 , AutoPoints [ 1 ] [ 0 ] , AutoPoints [ 1 ] [ 1 ] , AutoPoints [ 1 ] [ 2 ] ,AutoPoints [ 2 ] [ 0 ] , AutoPoints [ 2 ] [ 1 ] , AutoPoints [ 2 ] [ 2 ] , 10 ) ;
              ponto [ playerid ]  =  2 ;
              retornar  1 ;
         }
         caso  2 :
         {
              DisablePlayerRaceCheckpoint ( playerid ) ;
              SetPlayerRaceCheckpoint ( playerid, 0 , AutoPoints [ 2 ] [ 0 ] , AutoPoints [ 2 ] [ 1 ] , AutoPoints [ 2 ] [ 2 ] ,AutoPoints [ 3 ] [ 0 ] , AutoPoints [ 3 ] [ 1 ] , AutoPoints [ 3 ] [ 2 ] , 10 ) ;
              ponto [ playerid ]  =  3 ;
              retornar  1 ;
         }
         caso  3 :
         {
              DisablePlayerRaceCheckpoint ( playerid ) ;
              SetPlayerRaceCheckpoint ( playerid, 0 , AutoPoints [ 3 ] [ 0 ] , AutoPoints [ 3 ] [ 1 ] , AutoPoints [ 3 ] [ 2 ] ,AutoPoints [ 4 ] [ 0 ] , AutoPoints [ 4 ] [ 1 ] , AutoPoints [ 4 ] [ 2 ] , 10 ) ;
              ponto [ playerid ]  =  4 ;
              retornar  1 ;
         }
         caso  4 :
         {
              DisablePlayerRaceCheckpoint ( playerid ) ;
              SetPlayerRaceCheckpoint ( playerid, 0 , AutoPoints [ 4 ] [ 0 ] , AutoPoints [ 4 ] [ 1 ] , AutoPoints [ 4 ] [ 2 ] ,AutoPoints [ 5 ] [ 0 ] , AutoPoints [ 5 ] [ 1 ] , AutoPoints [ 5 ] [ 2 ] , 10 ) ;
              ponto [ playerid ]  =  5 ;
              retornar  1 ;
         }
         caso  5 :
         {
              DisablePlayerRaceCheckpoint ( playerid ) ;
              SetPlayerRaceCheckpoint ( playerid, 0 , AutoPoints [ 5 ] [ 0 ] , AutoPoints [ 5 ] [ 1 ] , AutoPoints [ 5 ] [ 2 ] ,AutoPoints [ 6 ] [ 0 ] , AutoPoints [ 6 ] [ 1 ] , AutoPoints [ 6 ] [ 2 ] , 10 ) ;
              ponto [ playerid ]  =  6 ;
              retornar  1 ;
         }
         caso  6 :
         {
              DisablePlayerRaceCheckpoint ( playerid ) ;
              SetPlayerRaceCheckpoint ( playerid, 0 , AutoPoints [ 6 ] [ 0 ] , AutoPoints [ 6 ] [ 1 ] , AutoPoints [ 6 ] [ 2 ] ,AutoPoints [ 7 ] [ 0 ] , AutoPoints [ 7 ] [ 1 ] , AutoPoints [ 7 ] [ 2 ] , 10 ) ;
              ponto [ playerid ]  =  7 ;
              retornar  1 ;
         }
         caso  7 :
         {
              DisablePlayerRaceCheckpoint ( playerid ) ;
              SetPlayerRaceCheckpoint ( playerid, 0 , AutoPoints [ 7 ] [ 0 ] , AutoPoints [ 7 ] [ 1 ] , AutoPoints [ 7 ] [ 2 ] ,AutoPoints [ 7 ] [ 0 ] , AutoPoints [ 7 ] [ 1 ] , AutoPoints [ 7 ] [ 2 ] , 10 ) ;
              ponto [ playerid ]  =  8 ;
              retornar  1 ;
         }
         caso  8 :
         {
            se ( IsPlayerInVehicle ( playerid, carroauto [ playerid ] ) )
            {
              novo Float : lataria;
              GetVehicleHealth ( carroauto [ playerid ] , lataria ) ;
              se ( lataria < 87 )
              {
                DisablePlayerRaceCheckpoint ( playerid ) ;
                novo veículo atual;
                currentveh =  GetPlayerVehicleID ( playerid ) ;
                DestruirVeículo ( veículoatual ) ;
                SendClientMessage ( playerid, - 1 , "(AUTO ESCOLA) Reprovado!! Você danificou muito a lataria do veículo." ) ;
                retornar  1 ;
              }
              DisablePlayerRaceCheckpoint ( playerid ) ;
              GameTextForPlayer ( playerid, "AUTO ESCOLA COMPLETA" , 3000 , 1 ) ;
              pDados [ playerid ] [ Carteira ]  =  1 ;
              InAutoEscola [ playerid ]  =  0 ;
              novo veículo atual;
              currentveh =  GetPlayerVehicleID ( playerid ) ;
              DestruirVeículo ( veículoatual ) ;
              retornar  1 ;
            }
            outro
            {
                DisablePlayerRaceCheckpoint ( playerid ) ;
                novo veículo atual;
                currentveh =  GetPlayerVehicleID ( playerid ) ;
                DestruirVeículo ( veículoatual ) ;
                SendClientMessage ( playerid, - 1 , "(AUTO ESCOLA) Reprovado!! Você não está em um veículo da Auto Escola." ) ;
                retornar  1 ;
            }
         }
     }
    retornar  1 ;
}
 
public OnDialogResponse ( playerid, dialogid, response, listitem, inputtext [ ] )
{
    if ( dialogid == DIALOG_AUTOESCOLA )
    {
        se ( resposta ==  1 )
        {
            InAutoEscola [ playerid ]  =  1 ;
            novo Float : X, Float : Y, Float : Z;
            ObterPosiçãoDoJogador ( idDoJogador,X,Y,Z ) ;
            carroauto [ playerid ]  =  CreateVehicle ( 466 , X,Y,Z, 297.6633 , 0 , 0 , - 1 ) ;
            ColocarJogadorNoVeículo ( playerid, carroauto [ playerid ] , 0 ) ;
            SendClientMessage ( playerid, - 1 , "(AUTO ESCOLA) Você iniciou a auto escola,siga as setas." ) ;
            SetPlayerRaceCheckpoint ( playerid, 0 , AutoPoints [ 0 ] [ 0 ] , AutoPoints [ 0 ] [ 1 ] , AutoPoints [ 0 ] [ 2 ] ,AutoPoints [ 1 ] [ 0 ] , AutoPoints [ 1 ] [ 1 ] , AutoPoints [ 1 ] [ 2 ] , 10 ) ;
            ponto [ playerid ]  =  1 ;
            GivePlayerMoney ( playerid, - 200 ) ;
            retornar  1 ;
        }
        se ( resposta ==  0 )
        {
            SendClientMessage ( playerid, - 1 , "(AUTO ESCOLA) Você desistiu da auto escola." ) ;
            GivePlayerMoney ( playerid, - 200 ) ;
            retornar  1 ;
        }
    }
    retornar  1 ;
}
 
#fim
