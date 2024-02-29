# Create OCSP Certs and OCSP Responder for Testing

This is a very simple docker wrapper around openssl to give a basic CA and OCSP responder.

1. Private CA and intermediate cert will be created
2. Listen on a specific port for OCSP validation
3. Create client certs and server certs (with SAN wildcard)
4. Validate a cert
5. Revoke a cert

__NOTE__: This will just create certs for testing and very basic openssl commands for the responder. This is for testing only.

## Building

Select directory of Repo and run:

```
docker build -t ocsp:latest .
```

## Running

Pass in a root doamin for the CA and the OCSP URL you would like to have in the OCSP extension in the certificates (this will be used as the OCSP responder to validate the cert).

```
docker run -d --restart=always -e ROOT_DOMAIN=lukesprojects.com -e OCSP_URL=http://10.0.16.5:2560 --name ocsp -p 2560:2560 ocsp:latest
```

## Creating Certs

### Creating Certificates with a wildcard for a domain

Provide a certificate name and domain:

```
docker exec -it ocsp ./create_san_wildcard_cert cluster-1 kurt-re.demo.redislabs.com
```

### Creating Certificates for clients or without the wildcard

```
docker exec -it ocsp ./create_cert client-1 client-1 > client-1_cert.pem
```

## Creating a new cert 

If you revoke a cert (see below) and would like to create a new cert with the same domain just call one of the create methods with a new name.

Example:

```
docker exec -it ocsp ./create_san_wildcard_cert cluster-2 kurt-re.demo.redislabs.com
```


## Retrieving

Retrieve the cert using it's name

```
docker exec -it ocsp ./get_cert cluster-1 > /etc/opt/redislabs/cluster-1_cert.pem
```

You can also get the key:

```
docker exec -it ocsp ./get_key cluster-1 > /etc/opt/redislabs/cluster-1_key.pem
```

And the cert CA chain:

```
docker exec -it ocsp ./get_chain > /etc/opt/redislabs/ca-chain.pem
```

## OCSP Status

Get the OCSP response for the cert using openssl to query the OCSP responder port in the container

```
openssl ocsp -CAfile ca-chain.pem -url http://127.0.0.1:2560 -issuer ca-intermediate.pem -cert cluster-1_cert.pem
```

expected response:

```
Response verify OK
proxy.pem: good
        This Update: Jun 30 23:18:31 2022 GMT
```


## Revoking

```
docker exec -it ocsp ./revoke_cert cluster-1
```

## Credit

The idea and a lot of the initial scripts came from this blog post: https://ilhicas.com/2018/04/10/Creating-oscp-responder-docker.html.

I have filled in the blanks, provided openssl configs, and generally cleaned it up to work for my use cases.