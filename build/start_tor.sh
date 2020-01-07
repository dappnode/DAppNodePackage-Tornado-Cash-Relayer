#!/bin/sh 

HIDDEN_SERVICE_DIR=/hidden_service

# Generate key if not present
if [ ! -f $HIDDEN_SERVICE_DIR/key ]; then
  shallot -f $HIDDEN_SERVICE_DIR/key ^tcsh
  grep 'BEGIN RSA' -A 99 $HIDDEN_SERVICE_DIR/key > $HIDDEN_SERVICE_DIR/private_key
fi

# Show Tor hidden service address
address=$(grep Found $HIDDEN_SERVICE_DIR/key | cut -d ':' -f 2 | tr -d ' ')
echo "#################################################"
echo "Hidden service address:"
echo
echo "http://${address}"
echo "or"
echo "https://${address}"
echo
echo "#################################################"

sed -i 's/example.com/'"$address"'/g' /etc/nginx/nginx.conf 

kill -HUP $(pgrep nginx | head -1)

exec /usr/bin/tor