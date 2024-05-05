#include <Servidor.mqh>

input string Host="0.0.0.0";
input ushort Port=8080;

Servidor servidor(Host, Port);

int OnInit() {
   EventSetTimer(2);
   return INIT_SUCCEEDED;
}


void OnDeinit(const int reason) {
   EventKillTimer();
   servidor.close_clean();
}

//------------------------------------------------------------------    OnTimer
void OnTimer() {
   string mensaje = servidor.receive_message();
   if (StringLen(mensaje) > 0) Print(mensaje);
}