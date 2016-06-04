+++
date = "2016-05-17T18:10:59+02:00"
title = "Connect Protocol"
+++

## Chatr Connect

After registering a UUID & public key you need to be able to make a peer-to-peer connection
with a specific client. To be able to do that Chatr has a "Connect" server. This server
basically functions as a middle man which allows clients to exchange IP addresses, as illustrated below:

<center><img src="/images/bob-alice-ip-exchange.png" alt="bob-alice-ip-exchange"></center>

## Connecting

The Connect server is a TLS server running on `chatr.captainbern.io:123`. The certificate
for this server can be retrieved at <a href="https://chatr.captainbern.io/certificate" target="_blank">`https://chatr.captainbern.io/certificate`</a>.

The connection process goes as follows:

<center><img src="/images/bob-connect.png" alt="bob-connect"></center>

The [PacketConnect](#packetconnect) is the **first** packet the server expects. If any other packet is sent **before** the [PacketConnect](#packetconnect) then
the server will send a [PacketDisconnect](#packetdisconnect) with message "Invalid Packet" and then close the connection.

In case the client ID you are trying to connect with is already connected to the server, the client will be disconnected with message "Already connected!". 
If the signature cannot be verified then the client will also be disconnected, this time with message "Failed to verify!".

If everything goes well and the signature was verified then the server will send a [PacketConnected](#packetconnected) to the client. The client may now
send other [packets](#packets).

## Peer-to-peer

Ater the client is connected to the Connect server it's ready to receive connection requests and make connections with other clients.
The peer-to-peer system works by opening a UDP socket on the same port the TLS client is running from.

TODO: finish this

## Packet specification

The packet format is quite simple and straightforward:

| Field name     | Field type   | Notes                                   |
| -------------- | ------------ | --------------------------------------- |
| Length         | `VarInt`     | Length of the packet data + packet ID.  |
| Opcode         | `uint8`      | The packet ID.                          |
| Packet Payload | byte array   | The packet data.                        |

Every packet is prefixed by a <a href="https://developers.google.com/protocol-buffers/docs/encoding#varints" target="_blank">VarInt</a> (the `Length` field) which
indicates the amount of bytes that remain in the packet. This also includes the packet ID (the `Opcode` field).

## Data Types

| Type      | Size (in bytes)      | Notes                                                                                                                      |
| --------- | -------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `bool`    | 1                    | `0x1` for `true` and `0x0` for `false`.                                                                                    |
| `VarInt`  | ≥ 1 & ≤ 5            | <a href="https://developers.google.com/protocol-buffers/docs/encoding#varints" target="_blank">Protocol Buffer VarInt</a>. |
| `byte`    | 1                    | Signed byte. (between -128 and 127)                                                                                        |
| `uint8`   | 1                    | Unsigned byte. (between 0 and 255)                                                                                         |
| `uint32`  | 4                    | Unsigned 32-bit integer. (between 0 and 4294967295)                                                                        |
| `long`    | 8                    | Signed 64-bit integer. (between -9223372036854775808 and 9223372036854775807)                                              |
| `String`  | ≥ 1 & ≤ 2147483652   | UTF-8 String prefixed by its length in bytes by a `VarInt`.                                                                |
| `UUID`    | 16                   | 16 bytes that represent a <a href="https://nl.wikipedia.org/wiki/Universally_unique_identifier" target="_blank">UUID</a>.  |
| `Address` | either 5 or 17 bytes | See [Address](#address).                                                                                                   |

## Address

The `Address` type is used to send either an IPv4 or IPv6 address over the network:

| Name    | Field type | Notes                                                          |
| --------| ---------- | -------------------------------------------------------------- |
| Version | `uint8`    | Indicates if the following Data is an IPv4 or an IPv6 address. |
| Data    | byte array | See below.                                                     |

If the value of the `Version` field is 4, the `Data` byte array is expected to be 4 bytes long and represent an IPv4 address. 
If the `Version` field is set to 6, the byte array should be 16 bytes long and represent an IPv6 address.


## Packets

| Opcode | Packet                                                          | Side     |
| ------ | --------------------------------------------------------------- | -------- |
| `0x0`  | [PacketConnect](#packetconnect)                                 | *Client* |
| `0x1`  | [PacketDisconnect](#packetdisconnect)                           | *Both*   |
| `0x2`  | [PacketConnected](#packetconnected)                             | *Server* |
| `0x3`  | [PacketPing](#packetping)                                       | *Server* |
| `0x4`  | [PacketPong](#packetpong)                                       | *Client* |
| `0x5`  | [PacketConnectionRequest](#packetconnectionrequest)             | *Both*   |
| `0x6`  | [PacketConnectionRequestAccept](#packetconnectionrequestaccept) | *Both*   |
| `0x7`  | [PacketConnectionRequestDenied](#packetconnectionrequestdenied) | *Both*   |
| `0x8`  | [PacketClientInfo](#packetclientinfo)                           | *Server* |

**Note: *Side* indicates who can send this packet.**

### PacketConnect

See [Connecting](#connecting).

| Field name | Field type | Notes                                                                                 |
| ---------- | ---------- | ------------------------------------------------------------------------------------- |
| Version    | `uint32`   | The protocol version. Ignored by the server.                                          |
| UUID       | `UUID`     | Your client id.                                                                       |
| Signature  | byte array | Result of signing the UUID bytes with your private key. Length prefixed by an `Int32` |

**Note: This packet may only be send once. Sending it more than once or after recieving a [PacketConnected](#packetconnected)
will result in being kicked from the server with message "Invalid Packet".**

### PacketDisconnect

After sending this packet, the server will close the connection. This packet is used as a way to give feedback
to the clients as to why the connection was closed.

Clients can also send this packet to the server when they disconnect (but it's not mandatory). The server
will close the connection after receiving this packet but will ignore the message.

| Field name | Field type | Notes              |
| ---------- | ---------- | ------------------ |
| Message    | `String`   | Disconnect reason. |

### PacketConnected

This packet has no fields. It's just an empty packet to let the client know the connection was successful.

### PacketPing

This packet is sent at least once every 5 seconds by the server (after a [PacketPong](#packetpong) is send back). If the server does
not receive a packet within 15 seconds after sending this packet, a [PacketDisconnect](#packetdisconnect) will be send
with as message "Time out" and the connection will be closed.

| Field name | Field type | Notes       |
| ---------- | ---------- | ----------- |
| PingID     | `long`     | The pingID. |

### PacketPong

After receiving a [PacketPing](#packetping) you should send a PacketPong containing the PingID of the last received ping packet.
If the pingID inside the PacketPong does not match the pingID in the [PacketPing](#packetping) sent by the server it will be ignored.

| Field name | Field type | Notes       |
| ---------- | ---------- | ----------- |
| PingID     | `long`     | The pingID. |

### PacketConnectionRequest

With the PacketConnectionRequest you can request the IP address of a specific client. The server will forward
this packet to the destined client. In case the destined client is not connected you will receive a [PacketConnectionDenied](#packetconnectiondenied).

It's also possible to receive this packet from the server. You can reply to it by either sending a [PacketConnectionDenied](#packetconnectiondenied) to
deny the request or a [PacketConnectionAccept](#packetconnectionaccept) to accept the request.

| Field name      | Field type | Notes      |
| --------------- | ---------- | ---------- |
| UUID            | `UUID`     | See below. |
| PrivateEndpoint | `Address`  | See below. |

When sending this packet the `UUID` field should be the UUID of the target client and the `PrivateEndpoint` should be your own private endpoint
your Peer2Peer client is running on (should be the same port as the port of the TCP client that is connected to the server).

When receiving this packet the `UUID` and the `PrivateEndpoint` fields belongs to the sender.

### PacketConnectionRequestAccept

This packet is used to accept a [PacketConnectionRequest](#packetconnectionrequest).

| Field name      | Field type | Notes      |
| --------------- | ---------- | ---------- |
| UUID            | `UUID`     | See below. |
| PrivateEndpoint | `Address`  | See below. |

### PacketConnectionRequestDenied

| Field name      | Field type | Notes      |
| --------------- | ---------- | ---------- |
| UUID            | `UUID`     | See below. |

### PacketClientInfo

| Field name     | Field type | Notes      |
| -------------- | ---------- | ---------- |
| UUID           | `UUID`     | See below. |
| PublicEndpoint | `Address`  | See below. |

After accepting a [PacketConnectionRequest](#packetconnectionrequest) the server will send this packet to both parties 
