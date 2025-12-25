#if defined _datagram_included
  #endinput
#endif
#define _datagram_included

native DGram_Create();
native DGram_Destroy(DGram:id);
native DGram_Send(DGram:id, const data[], size, const address[], port);
native DGram_Receive(DGram:id, data[], size, address[], &port);
