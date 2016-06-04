+++
date = "2016-05-17T18:10:37+02:00"
title = "Rest API"
+++

## Chatr REST API

The Chatr REST API allows you to register a UUID and corresponding public key.
Chatr REST API follows the standard REST principles and makes use of versionized
routes to ensure compatibility between multiple versions of the service.

## Getting Started

Before using the API, you should first create a <a href="https://nl.wikipedia.org/wiki/Universally_unique_identifier" target="_blank">UUID</a>. Most modern programming
languages have this functionality built-in.

Once you have created the UUID, you should generate an RSA KeyPair. We suggest you to
make this keypair at least 4096 bits.

Now your application should store this keypair somewhere, as it will be used to
authenticate with the Chatr Service(s).

## Authentication

The REST server will check the `Chatr-PublicKey-Signature` header when registering a new
UUID and public key or when updating the public key of an already registered UUID.

The header's value is the <a href="http://tools.ietf.org/html/rfc4648#section-4" target="_blank">Base64</a> encoded representation
of the signature of the **entire body of the request**, made using the private key.

Example in Java:
```java
KeyPair myKeyPair = ...;
byte[] requestBody = ...;

Signature signature = Signature.getInstance("SHA256withRSA", "BC"); // in the example we used BouncyCastle as the signature-provider
signature.initSign(myKeyPair.getPrivate()));
signature.update(requestBody);
byte[] signedPublicKey = signature.sign();

String theHeaderSignature = Base64.getEncoder().encodeToString(signedPublicKey);
```

## Response

Every response is in JSON format. The body of the JSON may vary depending on
whether or not the API call was successful or not.

Successful response format:

| Key         | Description                                                          |
| ----------- | -------------------------------------------------------------------- |
| `clientId`  | The UUID that was used in the request.                               |
| `publicKey` | The public key that is currently registered with the requested UUID. |

In case of a failed API call, the respone will look like this:

| Key             | Description                            |
| --------------- | -------------------------------------- |
| `error_message` | A short message describing the error.  |
| `error_type`    | The error type.                        |

Possible error types:

- `InvalidClientIdException`: thrown in case the given clientId is not the correct format.
- `ClientAlreadyRegisteredException`: thrown when trying to register a clientId that is already registered.
- `ClientDoesNotExistException`: thrown when trying to get or refresh the public key of a client that does not exist.
- `InvalidPublicKeyException`: thrown in case the public key is invalid.
- `InvalidSignatureException`: thrown in case the signature in the `Chatr-PublicKey-Signature` does not match the request body.

## Errors

In case the API call fails, the server will also reply with a specific status code.
These are all the possible status codes and their meanings:

| Code  | Description                 |
| ----- | --------------------------- |
| `200` | OK.                         |
| `401` | Invalid signature.          |
| `404` | Target UUID does not exist. |
| `500` | Internal server error.      |

## Registering a UUID & KeyPair

`PUT api/1/clients/{clientId}`

You can register a UUID and KeyPair by making a `PUT` request to the server. The body of the request should be a JSON object with a "key" property containing the
<a href="http://tools.ietf.org/html/rfc4648#section-4" target="_blank">Base64</a>  formatted public key, as illustrated below:

```json
{"key":"MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAwAZ50Q2oNoT1dthiO8jFcU7P2HNP0qrEdDVz1zBbGAw\/\/Eq49\/FvHrhGzWZw78A+1cFhtYqt9asZTDOx5Zu3LguUUMMTkBvXi0I58da0sEyKYYQAkl2yTt7DiUpFIePPCiAlCzbi6f2V\/uzwGxUnNIUHuicZ19+7EmIedkGJ+Ca09fDtCCNWodYtcSCyEG4Q7M6FS\/534qOxjxLauHk6XVqyNHvAL20pqLcTyyfPUiykDlOixZfrbrYH9YukFoeGTyOozPAJhDrZhavuxkBmMOFkQVP3R1US+WF\/FUbOGGzVpiRSz3l+t07BAeWho0YhPTTa7Pj7thU5dlqp0kyjepAYql\/9DT5nx8rF9jumlrheZZcZyEgISQCDaixeL4swJ5V4gDDsTBpSrCeZa\/zpruYYStQWCEbOPI5XRvWTjM\/b2oNN1qp9AF4CYtDSuLgpdJQvYKE4RWmXaCau6GpiUiEH4tGzyAcN25h+1KV0BZXAYE5CtNUsNR4wtizhD4zHqcmLLB5GI6Rq5mbeBSCasIpFnqqG8i87MzSriYlhTD5pJBqg1sSCcGRKOBPzbGkKmwvOOOGwjMkbRGmrQnBDRT4DvGbiEq9h166mH\/+qHBA6kqTUdiYrsKyq4jS8WVb\/Of4O5Acex5+9hfGYiXglJ7W9+HNXwpAppoA\/Cj16EVMCAwEAAQ=="}
```

**Note that this request requires [Authentication](#authentication).**

If your request was successful the server will return a JSON object which represents the registered client id and public key on the server, as shown in this example:

```json
{"clientId":"560fc470-0b71-47da-b8d2-117188f265d9","publicKey":"MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAwAZ50Q2oNoT1dthiO8jFcU7P2HNP0qrEdDVz1zBbGAw\/\/Eq49\/FvHrhGzWZw78A+1cFhtYqt9asZTDOx5Zu3LguUUMMTkBvXi0I58da0sEyKYYQAkl2yTt7DiUpFIePPCiAlCzbi6f2V\/uzwGxUnNIUHuicZ19+7EmIedkGJ+Ca09fDtCCNWodYtcSCyEG4Q7M6FS\/534qOxjxLauHk6XVqyNHvAL20pqLcTyyfPUiykDlOixZfrbrYH9YukFoeGTyOozPAJhDrZhavuxkBmMOFkQVP3R1US+WF\/FUbOGGzVpiRSz3l+t07BAeWho0YhPTTa7Pj7thU5dlqp0kyjepAYql\/9DT5nx8rF9jumlrheZZcZyEgISQCDaixeL4swJ5V4gDDsTBpSrCeZa\/zpruYYStQWCEbOPI5XRvWTjM\/b2oNN1qp9AF4CYtDSuLgpdJQvYKE4RWmXaCau6GpiUiEH4tGzyAcN25h+1KV0BZXAYE5CtNUsNR4wtizhD4zHqcmLLB5GI6Rq5mbeBSCasIpFnqqG8i87MzSriYlhTD5pJBqg1sSCcGRKOBPzbGkKmwvOOOGwjMkbRGmrQnBDRT4DvGbiEq9h166mH\/+qHBA6kqTUdiYrsKyq4jS8WVb\/Of4O5Acex5+9hfGYiXglJ7W9+HNXwpAppoA\/Cj16EVMCAwEAAQ=="}
```

## Refreshing a KeyPair

`POST api/1/clients/{clientId}`

After registering a UUID you can refresh the keypair by making a `POST` request. We strongly suggest you to refresh the keypair every time the user
open your application. In the Chatr android app the keypair is refreshed every time the user logs in.

This process is very similar to registering a UUID. The only difference is that the body should contain
your new public key (also as a JSON object) but the header is created using your old private key (the one that belongs to the public key that is currently on the server).
See [Registering a UUID & KeyPair](#registering-a-uuid-keypair) for an example body.

**Note that this request requires [Authentication](#authentication).**

Again, if your request was successful the server will return a JSON object which represents the registered client id and public key on the server.
See [Registering a UUID & KeyPair](#registering-a-uuid-keypair) for an example reply.

## Getting a client

`GET api/1/clients/{clientId}`

You can find another client's public key by making a `GET` request. This will return a JSON object containing the
target client's clientId and it's public key in <a href="http://tools.ietf.org/html/rfc4648#section-4" target="_blank">Base64</a> format.

In case the target client does not exist an [error](#errors) will be shown, else the server will return a JSON object formatted
in the same was as when you [register](#registering-a-uuid-keypair) or [refresh](#refreshing-a-keypair) a client.

Here is an example reply:

```json
{"clientId":"560fc470-0b71-47da-b8d2-117188f265d9","publicKey":"MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAwAZ50Q2oNoT1dthiO8jFcU7P2HNP0qrEdDVz1zBbGAw\/\/Eq49\/FvHrhGzWZw78A+1cFhtYqt9asZTDOx5Zu3LguUUMMTkBvXi0I58da0sEyKYYQAkl2yTt7DiUpFIePPCiAlCzbi6f2V\/uzwGxUnNIUHuicZ19+7EmIedkGJ+Ca09fDtCCNWodYtcSCyEG4Q7M6FS\/534qOxjxLauHk6XVqyNHvAL20pqLcTyyfPUiykDlOixZfrbrYH9YukFoeGTyOozPAJhDrZhavuxkBmMOFkQVP3R1US+WF\/FUbOGGzVpiRSz3l+t07BAeWho0YhPTTa7Pj7thU5dlqp0kyjepAYql\/9DT5nx8rF9jumlrheZZcZyEgISQCDaixeL4swJ5V4gDDsTBpSrCeZa\/zpruYYStQWCEbOPI5XRvWTjM\/b2oNN1qp9AF4CYtDSuLgpdJQvYKE4RWmXaCau6GpiUiEH4tGzyAcN25h+1KV0BZXAYE5CtNUsNR4wtizhD4zHqcmLLB5GI6Rq5mbeBSCasIpFnqqG8i87MzSriYlhTD5pJBqg1sSCcGRKOBPzbGkKmwvOOOGwjMkbRGmrQnBDRT4DvGbiEq9h166mH\/+qHBA6kqTUdiYrsKyq4jS8WVb\/Of4O5Acex5+9hfGYiXglJ7W9+HNXwpAppoA\/Cj16EVMCAwEAAQ=="}
```
