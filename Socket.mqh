// https://www.mql5.com/en/forum/91815

#define BYTE              uchar
#define WORD              ushort
#define DWORD             int
#define DWORD_PTR         ulong
#define SOCKET            uint

#define MAKEWORD(a, b)      ((WORD)(((BYTE)(((DWORD_PTR)(a)) & 0xff)) | ((WORD)((BYTE)(((DWORD_PTR)(b)) & 0xff))) << 8))

#define WSADESCRIPTION_LEN      256
#define WSASYS_STATUS_LEN       128

#define INVALID_SOCKET  (SOCKET)(~0)
#define SOCKET_ERROR    (-1)
#define NO_ERROR        0
#define SOMAXCONN       128

#define AF_INET         2 // internetwork: UDP, TCP, etc.
#define SOCK_STREAM     1
#define IPPROTO_TCP     6

#define SD_RECEIVE      0x00
#define SD_SEND         0x01
#define SD_BOTH         0x02

#define IOCPARM_MASK    0x7f            /* parameters must be < 128 bytes */
#define IOC_IN          0x80000000      /* copy in parameters */
#define _IOW(x,y,t)     (IOC_IN|(((int)sizeof(t)&IOCPARM_MASK)<<16)|((x)<<8)|(y))
#define FIONBIO         _IOW('f', 126, int) /* set/clear non-blocking i/o */
//------------------------------------------------------------------    struct WSAData
struct WSAData
  {
   WORD              wVersion;
   WORD              wHighVersion;
   char              szDescription[WSADESCRIPTION_LEN+1];
   char              szSystemStatus[WSASYS_STATUS_LEN+1];
   ushort            iMaxSockets;
   ushort            iMaxUdpDg;
   char              lpVendorInfo[];
  };

#define LPWSADATA               char&
//------------------------------------------------------------------    struct sockaddr_in
struct sockaddr_in
  {
   ushort            sin_family;
   ushort            sin_port;
   ulong             sin_addr; //struct in_addr { ulong s_addr; };
   char              sin_zero[8];
  };
//------------------------------------------------------------------    struct sockaddr
struct sockaddr
  {
   ushort            sa_family; // Address family.
   char              sa_data[14]; // Up to 14 bytes of direct address.
  };
#define LPSOCKADDR      char&

struct ref_sockaddr { char ref[2+14]; };

void sockaddrIn2RefSockaddr( sockaddr_in& sai, ref_sockaddr& rsa ) {
  // family
  rsa.ref[ 0] = (char) (( sai.sin_family      ) & 0xff );
  rsa.ref[ 1] = (char) (( sai.sin_family >> 8 )) ;
  // port
  rsa.ref[ 2] = (char) (( sai.sin_port        ) & 0xff) ;
  rsa.ref[ 3] = (char) (( sai.sin_port >>  8  ) );
  // address
  rsa.ref[ 4] = (char) (( sai.sin_addr        ) & 0xff );
  rsa.ref[ 5] = (char) (( sai.sin_addr >>  8  ) & 0xff );
  rsa.ref[ 6] = (char) (( sai.sin_addr >> 16  ) & 0xff );
  rsa.ref[ 7] = (char) (( sai.sin_addr >> 24  ) & 0xff );
  rsa.ref[ 8] = (char) (( sai.sin_addr >> 32  ) & 0xff );
  rsa.ref[ 9] = (char) (( sai.sin_addr >> 40  ) & 0xff );
  rsa.ref[10] = (char) (( sai.sin_addr >> 48  ) & 0xff );
  rsa.ref[11] = (char) (( sai.sin_addr >> 56  ) & 0xff );
  // zero
  rsa.ref[12] = 0;
  rsa.ref[13] = 0;
  rsa.ref[14] = 0;
  rsa.ref[15] = 0;
}

//------------------------------------------------------------------    import Ws2_32.dll
#import "Ws2_32.dll"
int WSAStartup(WORD wVersionRequested,LPWSADATA lpWSAData[]);
int WSACleanup();
int WSAGetLastError();

ushort htons(ushort hostshort);
ulong inet_addr(char& cp[]);
string inet_ntop(int Family,ulong &pAddr,char &pStringBuf[],uint StringBufSize);
ushort ntohs(ushort netshort);

SOCKET socket(int af,int type,int protocol);
int ioctlsocket(SOCKET s,int cmd,int &argp);
int shutdown(SOCKET s,int how);
int closesocket(SOCKET s);

// server function
int bind(SOCKET s,LPSOCKADDR name[],int namelen);
int listen(SOCKET s,int backlog);
SOCKET accept(SOCKET s,LPSOCKADDR addr[],int &addrlen);

// client function
int connect(SOCKET s,LPSOCKADDR name[],int namelen);
int send(SOCKET s,char &buf[],int len,int flags);
int recv(SOCKET s,char &buf[],int len,int flags);

#import