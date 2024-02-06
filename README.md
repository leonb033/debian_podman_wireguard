# debian_wireguard_docker
Installs podman and a wireguard container. Creates 2 different podman networks called **vpn** and **local** for split-tunneling. Wireguard connects to both networks to allow access of local services over the VPN connection. New podman containers should only be added to the **local** network. Script must be run by a sudo user that should own all the podman containers. Container is created in `~/podman/wireguard`.
### To run:
`wget -O script.sh https://raw.githubusercontent.com/leonb033/debian_podman_wireguard/main/script.sh && bash script.sh`
