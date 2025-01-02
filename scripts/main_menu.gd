extends Control

const GAME_SCENE = "res://scenes/game.tscn"

@onready var lobbies: ScrollContainer = $Menu/Lobbies
@onready var list_lobbies: Button = $Menu/ListLobbies

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
	$Menu/UseSteam.pressed.connect(_on_use_steam_pressed)
	
	list_lobbies.pressed.connect(_on_list_lobbies_pressed)
	
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
	NetworkManager.join_game()
	get_tree().call_deferred("change_scene_to_packed", preload(GAME_SCENE))
	
func _on_list_lobbies_pressed():
	print("List Lobbies pressed")
	SteamManager.list_lobbies()
	
func _on_use_steam_pressed():
	print("Use Steam pressed")
	SteamManager.initialize_steam()
	lobbies.show()
	list_lobbies.show()
	NetworkManager.active_network_type = NetworkManager.MULTIPLAYER_NETWORK_TYPE.STEAM
	
