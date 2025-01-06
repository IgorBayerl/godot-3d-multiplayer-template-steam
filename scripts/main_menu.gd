extends Control

const GAME_SCENE = "res://scenes/game.tscn"

@onready var lobbies: ScrollContainer = $Menu/Lobbies
@onready var list_lobbies: Button = $Menu/ListLobbies
@onready var switch_network_button: Button = %SwitchNetwork

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
	$Menu/Exit.pressed.connect(_on_exit_pressed)
	$Menu/HostGame.pressed.connect(_on_host_game_pressed)
	$Menu/JoinGame.pressed.connect(_on_join_game_pressed)
	switch_network_button.pressed.connect(_on_switch_network_pressed)
	switch_network_button.text = "Use Steam"
	
	list_lobbies.pressed.connect(_on_list_lobbies_pressed)

	NetworkManager.connect("network_changed",_on_network_changed)

	list_lobbies.hide()
	lobbies.hide()

# Callback for the Exit button
func _on_exit_pressed():
	get_tree().quit(0)

# Callback for the Host Game button
func _on_host_game_pressed():
	print("Host game pressed")
	NetworkManager.host_game()
	get_tree().call_deferred("change_scene_to_packed", preload(GAME_SCENE))

# Callback for the Join Game button
func _on_join_game_pressed():
	print("Join game pressed")
	handle_join_lobby()
	
func _on_list_lobbies_pressed():
	print("List Lobbies pressed")
	req_steam_list_lobbies()

func _on_network_changed() -> void:
	# Steam
	if(NetworkManager.active_network_type == NetworkManager.MULTIPLAYER_NETWORK_TYPE.STEAM):
		print(">>>>>>>>>>>>>>")
		SteamManager.initialize_steam()
		lobbies.show()
		list_lobbies.show()
		Steam.lobby_match_list.connect(_on_lobby_match_list)
		switch_network_button.text = "Use ENet"
		return
	#ENet
	if(NetworkManager.active_network_type == NetworkManager.MULTIPLAYER_NETWORK_TYPE.ENET):
		lobbies.hide()
		list_lobbies.hide()
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
	
#TODO Move this to a steam related class instead of main menu
func _on_lobby_match_list(lobbies: Array):
	print("On lobby match list \n %s" % lobbies)
	
	# Clear the current list of lobbies
	for lobby_child in $"Menu/Lobbies/VBoxContainer".get_children():
		lobby_child.queue_free()
		
	for lobby in lobbies:
		var lobby_name: String = Steam.getLobbyData(lobby, "name")
		
		if lobby_name != "":
			var lobby_mode: String = Steam.getLobbyData(lobby, "mode")
			
			var lobby_button: Button = Button.new()
			lobby_button.set_text(lobby_name + " | " + lobby_mode)
			lobby_button.set_size(Vector2(100, 30))
			lobby_button.add_theme_font_size_override("font_size", 13)
			
			var fv = FontVariation.new()
			lobby_button.add_theme_font_override("font", fv)
			lobby_button.set_name("lobby_%s" % lobby)
			lobby_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			# I want this to be have some kind of type safety
			lobby_button.connect("pressed", Callable(self, "handle_join_lobby").bind(lobby))
			
			$"Menu/Lobbies/VBoxContainer".add_child(lobby_button)

func handle_join_lobby(lobby_id: int = 0):
	NetworkManager.join_game(lobby_id)
	# TODO: after joining the lobby, we want to get the information of the other people in the same lobby and display somewhere
	get_tree().call_deferred("change_scene_to_packed", preload(GAME_SCENE))
	print(">>> Join lobby %s" % lobby_id)

func req_steam_list_lobbies():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	# NOTE: If you are using the test app id, you will need to apply a filter on your game name
	# Otherwise, it may not show up in the lobby list of your clients
	#Steam.addRequestLobbyListStringFilter("name", LOBBY_NAME, Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()


# Handles the menu the same way CounterStrike
# Where you automatically create a lobby when entering the menu.
# And anyone that is in the game can join it automatically
# So here i want to list everyone that is in the menu and consequentially with a lobby created
func list_friends_with_the_game(lobbies: Array):
	pass
