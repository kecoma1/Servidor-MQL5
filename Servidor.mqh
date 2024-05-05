#include <Socket.mqh>

class Servidor {
   public:
      string host;
      ushort port;
      SOCKET server_socket;
      
      Servidor(string _host, ushort _port);
      void close_clean();
      string receive_message(int buff_size=1024);
      
   private:
      bool init();
      SOCKET accept_client();
      
};

Servidor::Servidor(string _host, ushort _port) {
   this.host = _host;
   this.port = _port;
   this.server_socket = INVALID_SOCKET;
}

void Servidor::close_clean() {
   if (this.server_socket != INVALID_SOCKET) {
      closesocket(this.server_socket);
      this.server_socket = INVALID_SOCKET;
   }
   WSACleanup();
   Print("[INFO] - Servidor cerrado");
}

bool Servidor::init() {
   char wsaData[]; 
   ArrayResize(wsaData,sizeof(WSAData));
   
   // Inicializamos la librería
   int res = WSAStartup(MAKEWORD(2,2), wsaData);
   if(res!=0) { 
      Print("[ERROR] - Error al inicializar la librería"); 
      return false; 
   }

   // Inicializamos el socket
   this.server_socket = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
   if(this.server_socket == INVALID_SOCKET) {
      Print("[ERROR] - Error al crear el socket");
      this.close_clean();
      return false;
   }

   // bind de la dirección y el puerto
   Print("[INFO] - bind... "+this.host+":"+string(this.port));

   char ch[]; StringToCharArray(this.host,ch);
   sockaddr_in addrin;
   addrin.sin_family=AF_INET;
   addrin.sin_addr=inet_addr(ch);
   addrin.sin_port=htons(port);
   ref_sockaddr ref;
   sockaddrIn2RefSockaddr(addrin, ref);
   if(bind(this.server_socket,ref.ref,sizeof(addrin)) == SOCKET_ERROR) {
      Print("[ERROR] - Error al hacer bind");
      this.close_clean();
      return false;
   }

   // Establecemos el modo no bloqueante
   int non_block=1;
   res = ioctlsocket(this.server_socket, (int)FIONBIO, non_block);
   if(res!=NO_ERROR) { 
      Print("[ERROR] - Error al establecer el modo no bloqueante"); 
      this.close_clean();
      return false; 
   }

   // Listen
   if(listen(this.server_socket,SOMAXCONN) == SOCKET_ERROR) {
      Print("[ERROR] - Error al ejecutar listen");
      this.close_clean();
      return false;
   }

   Print("[INFO] - Servidor inicializado correctamente.");
   return  true;
}

SOCKET Servidor::accept_client() {
   if (this.server_socket == INVALID_SOCKET) return INVALID_SOCKET;
   ref_sockaddr ch;
   int len=sizeof(ref_sockaddr);
   SOCKET new_sock = accept(this.server_socket,ch.ref,len); 
   return new_sock;
}

string Servidor::receive_message(int buff_size=1024) {
   uchar tpl[];
   uchar client_msg[];
   string msg = "";

   if(this.server_socket == INVALID_SOCKET) this.init();
   else {
      SOCKET client=INVALID_SOCKET;
      
      ArrayResize(client_msg, buff_size);
      
      do {
         client=this.accept_client();
         if(client==INVALID_SOCKET) return msg;
         
         recv(client, client_msg, 1024, 0);
         
         msg += CharArrayToString(client_msg);
         if (StringLen(msg) > 0) Print("[INFO] Mensaje recibido: "+msg);
         
         StringToCharArray("OK", tpl);
         int slen=ArraySize(tpl);
         int res=send(client,tpl,slen,0);
         if(res==SOCKET_ERROR) Print("[ERROR] - Error al enviar datos");
         
         if(shutdown(client,SD_BOTH)==SOCKET_ERROR) Print("[ERROR] - Error al ejecutar shutdown");
         closesocket(client);
      } while(client!=INVALID_SOCKET);
   }
   
   return msg;
}