extends Node

const SERVER_PORT = 8080

var steam_network_peer: SteamMultiplayerPeer = SteamMultiplayerPeer.new()

var _players_spawn_node
var _hosted_lobby_id: int = 0

const LOBBY_NAME = "BAD"
const LOBBY_MODE = "CoOP"

func  _ready():
	Steam.lobby_created.connect(_on_lobby_created)

#func create_server_peer():
	#print("create_server_peer Steam")
	#steam_network_peer.create_host(SERVER_PORT)
	#Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, SteamManager.lobby_max_members)
	#multiplayer.multiplayer_peer = steam_network_peer
	
func host_server():
	print("host_server Steam")
	
	multiplayer.peer_connected.connect(_handle_player_connected)
	multiplayer.peer_disconnected.connect(_handle_player_disconnected)
	
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, SteamManager.lobby_max_members)


#func create_client_peer(target_lobby_id: int):
	#print("create_client_peer Steam -> %s" %target_lobby_id)
	#var identity_remote: int = 0
	#Steam.joinLobby(target_lobby_id)
	#steam_network_peer.create_client(identity_remote, SERVER_PORT)
	#multiplayer.multiplayer_peer = steam_network_peer
func join_server(target_lobby_id: int):
	print("join_server Steam -> %s" %target_lobby_id)
	Steam.lobby_joined.connect(_on_lobby_joined.bind())
	Steam.joinLobby(int(target_lobby_id))

func _handle_player_connected(id: int):
	print("handle player connected callback : %s" % id )
	
func _handle_player_disconnected(id: int):
	print("handle player disconnected callback : %s" % id )

func _on_lobby_created(connect: int, lobby_id):
	print("On lobby created")
	if connect == 1:
		_hosted_lobby_id = lobby_id
		print("Created lobby: %s" % _hosted_lobby_id)
		
		Steam.setLobbyJoinable(_hosted_lobby_id, true)
		
		Steam.setLobbyData(_hosted_lobby_id, "name", LOBBY_NAME)
		Steam.setLobbyData(_hosted_lobby_id, "mode", LOBBY_MODE)
		_create_host_peer()

func _create_host_peer():
	print("Create Host")
	var error = steam_network_peer.create_host(SERVER_PORT)
	
	if error == OK:
		multiplayer.set_multiplayer_peer(steam_network_peer)
		
		if not OS.has_feature("dedicated_server"):
			_add_player_to_game(1)
	else:
		print("error creating host: %s" % str(error))

func _on_lobby_joined(lobby: int, permissions: int, locked: bool, response: int):
	print("On lobby joined")
	
	if response == 1:
		var id = Steam.getLobbyOwner(lobby)
		if id != Steam.getSteamID():
			print("Connecting client to socket...")
			connect_socket(id)
	else:
		# Get the failure reason
		var FAIL_REASON: String
		match response:
			2:  FAIL_REASON = "This lobby no longer exists."
			3:  FAIL_REASON = "You don't have permission to join this lobby."
			4:  FAIL_REASON = "The lobby is now full."
			5:  FAIL_REASON = "Uh... something unexpected happened!"
			6:  FAIL_REASON = "You are banned from this lobby."
			7:  FAIL_REASON = "You cannot join due to having a limited account."
			8:  FAIL_REASON = "This lobby is locked or disabled."
			9:  FAIL_REASON = "This lobby is community locked."
			10: FAIL_REASON = "A user in the lobby has blocked you from joining."
			11: FAIL_REASON = "A user you have blocked is in the lobby."
		print(FAIL_REASON)
		
func connect_socket(steam_id: int):
	var error = steam_network_peer.create_client(steam_id, SERVER_PORT)
	if error == OK:
		print("Connecting peer to host...")
		multiplayer.set_multiplayer_peer(steam_network_peer)
	else:
		print("Error creating client: %s" % str(error))

func _add_player_to_game(id: int):
	print("Player %s joined the game!" % id)
#	TODO implement this shit
