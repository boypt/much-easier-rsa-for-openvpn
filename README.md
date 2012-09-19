#Much-easier-rsa for Openvpn

A wrapper script for easy-rsa and openvpn, creates a **ready-to-run** configure tar for both server and client whthin extremely simple steps.

All those config files are based on examples that ship together within your distribution.

##Features

 * Provide tared config which ready for any server distribution.
 * Random VPN subnet will be generated to avoid conflict.
 * Random digital subffixed server/client CommonName will be assigned (if you don't provide one) for clearer management.
 * Configuration file is copied from the distributed OpenVPN from your distribution, which includes full explanations to options.
 * tls-auth enabled by default. 


![](http://apt-blog.net/wp-content/uploads/2012/05/ovpn_menu.png)