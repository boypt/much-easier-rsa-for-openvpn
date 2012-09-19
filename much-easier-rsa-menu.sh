#!/bin/bash

OPENVPNEXAMPLE="/usr/share/openvpn/examples/"
EASYRSA="/usr/share/openvpn/easy-rsa/"
PORT="9812"
SERVERIP="4.3.2.1"
VPNSUBNET="10.$((RANDOM%=255)).$((RANDOM%=255)).0"
VPNMASK="255.255.255.192"

msg_red() {
    echo -e "\033[31;1m $1\033[0m";
}

msg_yellow () {
    echo -e "\033[33;1m $1\033[0m";
}

#ovpn path test

if [[ ! -d $OPENVPNEXAMPLE ]] || [[ ! -d $EASYRSA ]]; then

    #ubuntu
    OPENVPNEXAMPLE="/usr/share/doc/openvpn/examples/sample-config-files/"
    EASYRSA="/usr/share/doc/openvpn/examples/easy-rsa/2.0/"
    if [[ ! -d $OPENVPNEXAMPLE ]] || [[ ! -d $EASYRSA ]]; then
        msg_red "OpenVPN Example/Easy-rsa not found, edit script for a correnct path."
    fi
fi


ALLTAREDCONF=$1

TEMPDIR=`mktemp -d`
cd $TEMPDIR



msg_usefule () {
    msg_red "iptables commands below may be useful:"
    echo
    echo "iptables -A INPUT -p udp --dport $PORT -j ACCEPT"
    echo "iptables -A FORWARD -i tun+ -j ACCEPT"
    echo "iptables -t nat -A POSTROUTING -s $VPNSUBNET/24 -j SNAT --to-source $SERVERIP"
}


notify () {
    msg_red "Working Dir: $TEMPDIR"
    msg_red "VPN Network: $VPNSUBNET"
    msg_red "SERVERIP: $SERVERIP"
    msg_red "PORT: $PORT"
    echo 
    echo "choose: 
    1) change SERVERIP
    2) change PORT
    3) build server keys
    4) build client keys
    5) pack all things and exit
    "
}

save_variables () {
    echo -e "VPN_NAME='$VPN_NAME'\nSVRNAME='$SVRNAME'\nCLINAME='$CLINAME'\nPORT='$PORT'\nSERVERIP='$SERVERIP'\nVPNSUBNET='$VPNSUBNET'\nVPNMASK=$VPNMASK" > $TEMPDIR/CUSVARS
}

export_default () {
    export KEY_COUNTRY="CN"
    export KEY_PROVINCE="GD"
    export KEY_CITY="GZ"
    export KEY_ORG="WhatEver"
    export KEY_EMAIL="me@myhost.mydomain"
    export KEY_CN=$VPN_NAME
    export KEY_OU=$VPN_NAME
}


if [[ -f $ALLTAREDCONF ]]; then
    tar xfz $ALLTAREDCONF -C $TEMPDIR
    cd $TEMPDIR
    source CUSVARS
    cd easy-rsa
    source vars
    export_default
else
    msg_yellow "New config is to be generated."
    msg_red "Enter your VPN name:"
    read VPN_NAME

    cp -r $EASYRSA $TEMPDIR/easy-rsa
    cd easy-rsa
    sed "s/--interact //" -i build-ca build-key build-key-server


    SVRNAME=$VPN_NAME"-server"
    CLINAME=$VPN_NAME"-client"


    save_variables

    source vars
    export_default

    echo -e "\033[33;1m" 
    ./clean-all
    ./build-ca
    ./build-dh
    #cp /tmp/dh1024.pem keys/
    openvpn --genkey --secret keys/ta.key
    echo -e "\033[0m";

    echo -e "CA/DH are generated.\n\n"
    echo -e "Now ready to build keys.\n"
fi

build_server () {
    echo -e "\033[33;1m" 
    cd $TEMPDIR/easy-rsa

    export KEY_NAME=$SVRNAME-$RANDOM
    export KEY_CN=$KEY_NAME
    ./build-key-server $SVRNAME
    cd ..

    cp $OPENVPNEXAMPLE/server.conf .

    sed "s/^port.\+/port $PORT/;
    s/^server.\+/server $VPNSUBNET $VPNMASK/;
    s/^cert.\+/cert $SVRNAME.crt/;
    s/^key.\+/key $SVRNAME.key/;
    s/^;\(tls-auth.\+$\)/\1/;
    s/^;\(push \"redirect-gateway.\+\)/\1/;
    s/^;\(push \"dhcp-option.\+\)/\1/;
    s/^;\(duplicate-cn\)/\1/" -i server.conf

    mkdir $SVRNAME
    mv server.conf $SVRNAME
    cp easy-rsa/keys/{dh1024.pem,ta.key,ca.crt,$SVRNAME.crt,$SVRNAME.key} $SVRNAME
    tar cvfz $SVRNAME.tar.gz $SVRNAME

    echo -e "\033[0m";
    echo "Packed Server key: $SVRNAME.tar.gz"
}

build_client () {
    cd $TEMPDIR/easy-rsa

    echo "Client Name ? (Empty for random digits)"
    read NAME

    if [[ -z $NAME ]]; then
        NAME=$RANDOM
    fi

    echo -e "\033[33;1m" 
    CLINAMEIDNY="$CLINAME-$NAME"
    export KEY_NAME=$CLINAMEIDNY
    export KEY_CN=$KEY_NAME
    ./build-key $CLINAME

    cd ..
    cp $OPENVPNEXAMPLE/client.conf .

    sed "s/^remote.\+/remote $SERVERIP $PORT/;
    s/^cert.\+/cert $CLINAME.crt/;
    s/^key.\+/key $CLINAME.key/;
    s/^;\(tls-auth.\+$\)/\1/" -i client.conf 

    mkdir $CLINAMEIDNY
    mv client.conf $CLINAMEIDNY
    cp easy-rsa/keys/{ta.key,ca.crt,$CLINAME.crt,$CLINAME.key} $CLINAMEIDNY
    tar cvfz $CLINAMEIDNY.tar.gz $CLINAMEIDNY

    echo -e "\033[0m";
    echo "Packed Client key: $CLINAMEIDNY.tar.gz"
}

while true; do
    notify
    read CHOOSE
    case "$CHOOSE" in
      1)
          msg_yellow "Enter Your Server IP:"
          read SERVERIP
          save_variables
          ;;
      2)
          msg_yellow "Enter Your VPN Service PORT:"
          read PORT
          save_variables
          ;;
      3)
          build_server
          ;;
      4)
          build_client
          ;;
      5)
          cd $TEMPDIR
          TAR=/tmp/$VPN_NAME-all.tar.gz
          tar cfz $TAR .
          msg_red "All works saved in '$TAR'"
          msg_red "Working Dir: $TEMPDIR"
          msg_yellow "Packed config is ready: "
          ls $TEMPDIR/*.tar.gz
          msg_red "Save the this files to a safe place."
          echo 
          msg_usefule
          echo 
          echo
          exit 0
          ;;
      *)
        echo -e "not valid."
        ;;
    esac
done


