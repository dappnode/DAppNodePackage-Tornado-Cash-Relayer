#!/bin/sh 

if [ $NETWORK == "kovan" ];then
    export NET_ID=42
    export RPC_URL=http://kovan.dappnode:8545/
else
    export NET_ID=1
    export RPC_URL=http://fullnode.dappnode:8545/
fi

exec node app.js