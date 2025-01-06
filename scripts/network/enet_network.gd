extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var enet_network_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

# Old create_server_peer
func host_server():
	print("host_server ENet")
	enet_network_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = enet_network_peer
	
# Old create_client_peer
func join_server(_target_lobby_id: int):
	print("join_server ENet")
	enet_network_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = enet_network_peer
