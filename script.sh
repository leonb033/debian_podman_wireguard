clear

local_network="10.10.10.0/24"
wireguard_port="51820"
client_count=1

# returns current user's uid
get_uid() {
  echo $(id $(whoami) | grep -Eo 'uid=[0-9]+' | grep -Eo '[0-9]+')
}

# returns current user's gid
get_gid() {
  echo $(id $(whoami) | grep -Eo 'gid=[0-9]+' | grep -Eo '[0-9]+')
}

# replaces a string inside a file
# param 1: old string
# param 2: new string
# param 3: path to file
replace_string() {
  sudo sed -i "s|$1|$2|" $3
}

# local_network
echo "Enter local network. [default: $local_network]"
read -p ">>> "
if [[ $REPLY != "" ]]; then
  local_network=$REPLY
fi
clear

# wireguard_port
echo "Enter wireguard port. [default: $wireguard_port]"
read -p ">>> "
if [[ $REPLY != "" ]]; then
  wireguard_port=$REPLY
fi
clear

# client_count
echo "Enter client count. [default: $client_count]"
read -p ">>> "
if [[ $REPLY != "" ]]; then
  client_count=$REPLY
fi
clear

# summary
echo "local_network =   $local_network"
echo "wireguard_port =  $wireguard_port"
echo "client_count =    $client_count"
echo
echo "Press ENTER to start setup."
echo "Press CTRL + C to abort."
read
clear

# install podman
sudo apt update
sudo apt install podman podman-compose

# create podman networks
podman network rm vpn
podman network rm local
podman network create --subnet 10.13.13.0/24 --ip-range 10.13.13.0/24 vpn
podman network create --subnet $local_network --ip-range $local_network local

# create folders
mkdir -p ~/podman/wireguard

# generate compose file
cd ~/podman/wireguard
sudo wget -O compose.yaml https://raw.githubusercontent.com/leonb033/debian_podman_wireguard/main/compose.yaml
replace_string "<UID>" $(get_uid) compose.yaml
replace_string "<GID>" $(get_gid) compose.yaml
replace_string "<WG_PORT>" $wireguard_port compose.yaml
replace_string "<CLIENT_COUNT>" $client_count compose.yaml
replace_string "<LOCAL_NETWORK>" $local_network compose.yaml

# open wireguard port in nftables
sudo nft add rule inet firewall incoming udp dport $wireguard_port accept

# start wireguard container
podman-compose up -d --force-recreate
