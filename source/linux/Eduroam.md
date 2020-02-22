# Connecting to Eduroam Network

## Just one simple Step

Assuming that you are using `netctl`, eduroam networks can be easily accessed by placing the following profile in `/etc/netctl/`.

```bash
Connection='wireless'
Interface='<wlan interface>'
Security='wpa-configsection'
Description='eduroam network'
IP='dhcp'
TimeoutWPA=30
WPAConfigSection=(
  'ssid="eduroam"'
  'key_mgmt=WPA-EAP'
  'eap=PEAP'
  'proto=RSN'
  'phase2="auth=MSCHAPV2"'
  'anonymous_identity="<anonymous mail address>"'
  'identity="<identity mail address>"'
  'ca_cert="<path to *.pem>"'
  'password=hash:<password hash>'
)
```

The profile can then be used by calling

```bash
$ netctl start eduroam
```


## Obtaining the Password Hash

The hash used to specify the password can be generated using the `MD4` algorithm:

```bash
$ echo -n '<password>' | iconv -t utf16le | openssl md4
```

If you don't like typing your password into the shell, you might also use

```bash
$ read -sp"Password: " passwd
```

and pass `$passwd` to the echo function. Note that the `-s` parameter is not POSIX-compliant and depends on bash.
