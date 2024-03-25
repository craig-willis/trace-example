# TRACE Example

Generate GPG key
```
gpg --full-generate-key
```

Obtain API key from https://fred.stlouisfed.org/docs/api/fred/

Export environment variables"
```
export GPG_FINGERPRINT=
export GPG_PASSPHRASE=
export FRED_APIKEY=
```

Install dependences:
```
pip install pyshacl

https://github.com/transparency-certified/tro-utils
cd tro-utils
pip install -e .
```


Run example workflow
```
./tro.sh
```
