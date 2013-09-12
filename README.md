#Much-easier-rsa for Openvpn

A wrapper script for easy-rsa and openvpn, creates a **ready-to-run** configure tar for both server and client whthin extremely simple steps.


##Features

 * Provide tared config which ready for any server distribution.
 * Random VPN subnet will be generated to avoid conflict.
 * Random digital subffixed server/client CommonName will be assigned (if you don't provide one) for clearer management.
 * All those config files are based on examples that ship together within your distribution.
 * tls-auth enabled by default. 

##Usage

For new setup:
```
./much-easier-rsa-menu.sh
```

Just do as menu promote. When select `5`, all the files will be packed into a single `NAME-all.tar.gz`, you should save it somewhere safe. 
And if you want to sign some more certificates from this root CA latter on, put the tared file as argument.

```
./much-easier-rsa-menu.sh /path/to/YOUR-VPN-all.tar.gz
```

At last the script also provide you `iptables` commands that may be useful to setup the server as a VPN gateway.


![](http://apt-blog.net/wp-content/uploads/2012/05/ovpn_menu.png)
