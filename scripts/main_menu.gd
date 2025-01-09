extends Control

const GAME_SCENE = "res://scenes/game.tscn"

@onready var lobby_list = $Menu/LobbyList
@onready var refresh_lobbies: Button = %RefreshLobbies
@onready var switch_network_button: Button = %SwitchNetwork
@onready var join_game: Button = %JoinGame


const LOBBY_NAME = "BAD"
const LOBBY_MODE = "CoOP"


func _ready():
	print("Main menu ready...")
	# Check for dedicated server and host game automatically
	if OS.has_feature("dedicated_server"):
		print("Calling host game...")
		NetworkManager.host_game()
		get_tree().call_deferred("change_scene_to_packed", preload(GAME_SCENE))
	
	# Connect signals for buttons
	%Exit.pressed.connect(_on_exit_pressed)
	%HostGame.pressed.connect(_on_host_game_pressed)
	join_game.pressed.connect(_on_join_game_pressed)
	switch_network_button.pressed.connect(_on_switch_network_pressed)
	switch_network_button.text = "Use Steam"
	
	refresh_lobbies.pressed.connect(_on_refresh_lobbies_pressed)

	NetworkManager.network_changed.connect(_on_network_changed)

	refresh_lobbies.hide()
	lobby_list.hide()

func _on_exit_pressed():
	get_tree().quit(0)

func _on_host_game_pressed():
	NetworkManager.host_game()
	get_tree().call_deferred("change_scene_to_packed", preload(GAME_SCENE))

func _on_join_game_pressed():
	handle_join_lobby()
	
func _on_refresh_lobbies_pressed():
	req_steam_list_lobbies()

func _on_network_changed() -> void:
	# Steam
	if(NetworkManager.active_network_type == NetworkManager.MULTIPLAYER_NETWORK_TYPE.STEAM):
		SteamManager.initialize_steam()
		lobby_list.show()
		join_game.hide()
		refresh_lobbies.show()
		Steam.lobby_match_list.connect(_on_lobby_match_list)
		switch_network_button.text = "Use ENet"
		req_steam_list_lobbies()
		return
	#ENet
	if(NetworkManager.active_network_type == NetworkManager.MULTIPLAYER_NETWORK_TYPE.ENET):
		lobby_list.hide()
		join_game.show()
		refresh_lobbies.hide()
		Steam.lobby_match_list.disconnect(_on_lobby_match_list)
		switch_network_button.text = "Use Steam"
		return

func _on_switch_network_pressed():
	if(NetworkManager.active_network_type == NetworkManager.MULTIPLAYER_NETWORK_TYPE.STEAM):
		NetworkManager.set_network(NetworkManager.MULTIPLAYER_NETWORK_TYPE.ENET)
		return
	if(NetworkManager.active_network_type == NetworkManager.MULTIPLAYER_NETWORK_TYPE.ENET):
		NetworkManager.set_network(NetworkManager.MULTIPLAYER_NETWORK_TYPE.STEAM)
		return
	
func _on_lobby_match_list(lobbies_list: Array):
	var lobby_items: Array[LobbyConfig] = []

	for lobby_id in lobbies_list:
		var lobby_name: String = Steam.getLobbyData(lobby_id, "name")
		if lobby_name != "":
			var lobby_mode: String = Steam.getLobbyData(lobby_id, "mode")
			var num_of_members: int = Steam.getNumLobbyMembers(lobby_id)
			var max_members: int = Steam.getLobbyMemberLimit(lobby_id)
			var address: String = Steam.getLobbyData(lobby_id, "address")
			var lobby_index: int = lobbies_list.find(lobby_id)

			# Create a LobbyConfig instance
			var lobby_config = LobbyConfig.new(
				lobby_index,
				max_members,
				num_of_members,
				lobby_name,
				address
			)
			lobby_items.append(lobby_config)
	# This will set the value and the component will handle the render and filtering and other stuff
	lobby_list.lobby_items = lobby_items
	lobby_list.join_lobby_callback = handle_join_lobby

func handle_join_lobby(lobby_id: int = 0):
	print(">>> Join lobby %s" % lobby_id)
	SignalBus.lobby_joined.connect(_on_joined_lobby)
	NetworkManager.join_game(lobby_id)
	
func _on_joined_lobby(lobby_id: int):
	SignalBus.lobby_joined.disconnect(_on_joined_lobby)
	get_tree().call_deferred("change_scene_to_packed", preload(GAME_SCENE))

func req_steam_list_lobbies():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	# NOTE: If you are using the test app id, you will need to apply a filter on your game name
	# Otherwise, it may not show up in the lobby list of your clients
	#Steam.addRequestLobbyListStringFilter("name", LOBBY_NAME, Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()
