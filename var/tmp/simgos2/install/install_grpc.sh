#!/bin/sh

cd ~

sudo sed -i '$ a Install gRPC' /var/log/simgos2.log
echo  "Install gRPC"
if [ ! -f install-grpc.sh ]; then
    sudo wget http://simgos2.simpel.web.id/repos/php/extension/install-grpc.sh
    sudo sed -i -e 's/\r$//' install-grpc.sh
    sudo chmod +x install-grpc.sh
    sudo ./install-grpc.sh
fi
sudo sed -i 's/Install gRPC/Install gRPC ......... OK/g' /var/log/simgos2.log
