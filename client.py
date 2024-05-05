import socket

# Cretating a TCP socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connecting to the server
s.connect(("localhost", 8088))

# Message to send
msg = "sell"

s.sendall(msg.encode())