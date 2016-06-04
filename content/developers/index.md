+++
date = "2016-05-17T17:09:05+02:00"
title = "Overview"
type = "index"
+++

## Chatr

## 1. Introduction

   The Chatr Protocol is designed to simplify the security and establishment 
   of peer-to-peer connections.  This document describes the functions performed
   by the protocol, the program that implements it and its users.

### 1.1. Motivation

   Because of the increase of mass surveillance, privacy is becoming more and
   more important within our global civilization.  A lot of companies are forced
   to implement backdoors in their systems by their governments.  Encryption is
   part of the solution but there are still central servers that may or may not 
   be subjected to surveillance.  A lot of companies also depend on data mining, 
   which means your data is not 100% private by making use of the services 
   provided by those companies.  As an end user, you also don't know for sure
   whether or not your privacy is being respected or not. 

   To address those issues, the Chatr Protocol is designed around the principles
   of peer-to-peer networking.  The Chatr Protocol aims to help simplify establishing
   a peer-to-peer connection and  provides a way of securing said connection.   
   The Chatr Protocol makes use of UUIDs to identify users on the network.  Every
   user has its own UUID which is asigned to a public key.  Within this protocol,
   UUIDs are persistent.  While their usage is almost the same as that of an IP
   address, they are meant to be non volatile.  

### 1.2. Terminology

   The keywords MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD,
   SHOULD NOT, RECOMMENDED, MAY, and OPTIONAL, when they appear in this
   document, are to be interpreted as described in [RFC2119](https://www.ietf.org/rfc/rfc2119.txt).

   UUID:  A Universally Unique Identifier as described in [RFC4122](https://www.ietf.org/rfc/rfc4122.txt).

   Client:  A client is the protocol implementation that is using the system.
     This either means that the client has registered a UUID and public key on the server
     or is connected to the chatr-connect server.

   ClientID:  A UUID assigned to a specific client.

### 1.3. Scope

   The Chatr Protocol is intended to provide a simple but reliable service which
   can be used to establish secure peer-to-peer connections.  Clients within this
   system are identified by UUIDs which adds another layer of security (by obscurity).  
   Clients need to know the UUID of the client they wish to connect to. 

## 2. Registering a UUID & public key
   
   In order to register a UUID & public key, a client should (1) generate a 
   random UUID and (2) generate a new RSA keypair as per [RFC3347](https://www.ietf.org/rfc/rfc3447.txt).
   The client may now try to register the resulting UUID & public key (derived from the
   keypair it generated earlier).

   A UUID & public key can be easily registered or updated through an HTTP server.  You
   can also retrieve the public key of a specific user through the same server.

   The server essentially functions as a key-value store.  Clients can either add a new
   record, update an existing record or retrieve an existing record.

### 2.1. Full implementation requirements

### 2.1.1. Generating a UUID

   To keep the server as lightweight as possible, clients themself are responible for 
   generating a valid UUID.  The server will only check if the UUID has a valid format
   and hasn't been registered yet.  

### 2.1.2. Generating an RSA keypair

   To provide some form of authentication and to make sure a client cannot be impersonated 
   by another, every clientID is assigned to a public key.  This public key is publicly 
   available.  The public key is also used to secure the peer-to-peer connection.

### 2.1.3. Retrieving the public key of a specific client

   Clients can rerieve each other's public key. This is an essential part of securing
   the peer-to-peer connection and countering so called man-in-the-middle attacks.

## 3. Retrieving the IP address of a client

   The Chatr Protocol was designed with security and anonymity in mind.  The IP address
   of a client should not be exposed unless the client agrees with it.  The protocol
   functions as a network which clients connect to.  Clients can make a connection request
   to each other in order to retrieve each other's IP address.

### 3.1. Full implementation requirements

### 3.1.1. Connection requests

   In order to make a peer-to-peer connection with a specific client, the IP address of said
   client first needs to be obtained.  This is done in the form of connection request messages.
   Those connection requests can be either accepted, denied or ignored.  In case you accept a
   connection request then the server will exchange the IP addresses between both parties.  
   Imagine the following scenario where "Alice" wishes to start a peer-to-peer connection with
   "Bob".  Alice and Bob both have a registered UUID & public key on the server.  They also know
   each other's UUID and are connected to the Chatr network.  Alice sends a connection request to
   the server with Bob's UUID as destination.  The server will route this request to Bob.  Bob can
   now respond by sending a connection accept or connection denied message.  In case Bob ignores 
   the request, Alice should treat it as denied.  In case Bob accepts the connection request, then 
   the server will send Bob's IP address to Alice, and Alice's IP address to Bob.

   Connection requests have to be made per peer-to-peer connection.  As soon as the peer-to-peer 
   connection is interrupted or closed, a new connection request should be made because the IP
   address of any of the clients involved might have changed.

### 3.1.2. Offline clients

   The Chatr Protocol is a real-time protocol.  This means that it will not keep track or connection 
   requests made to clients that were offline at the time of the request.  In case a connection request
   is made to an offline client, the server will immediately respond with a connection denied message.

## 4. Authentication

   The protocol also provides a simple, yet powerful way to ensure clients are who they say they are.
   Passwords do not exist in the Chatr Protocol, instead it makes use of strong RSA keypairs.  Those
   keypairs are used to authenticate with the Chatr services, but are also used by the clients, in
   order to secure peer-to-peer connections. 

   When registering a UUID & public key, or when updating the public key of an existing UUID, a client
   needs to provide a signature which is the result of signing a piece of data with the private key.  
   The server uses the public key to verify the signature and integrity of the request.  In case the 
   signature is invalid, then the operation will be ignored and an error returned.
