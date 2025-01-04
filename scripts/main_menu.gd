extends Control

const GAME_SCENE = "res://scenes/game.tscn"

@onready var lobbies: ScrollContainer = $Menu/Lobbies
@onready var list_lobbies: Button = $Menu/ListLobbies

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
	req_steam_list_lobbies()
	
func _on_use_steam_pressed():
	print("Use Steam pressed")
	SteamManager.initialize_steam()
	lobbies.show()
	list_lobbies.show()
	NetworkManager.active_network_type = NetworkManager.MULTIPLAYER_NETWORK_TYPE.STEAM
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	
#TODO Move this to a steam related class instead of main menu
func _on_lobby_match_list(lobbies: Array):
	print("On lobby match list")
	
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
			lobby_button.connect("pressed", Callable(self, "join_lobby").bind(lobby))
			
			$"Menu/Lobbies/VBoxContainer".add_child(lobby_button)

func req_steam_list_lobbies():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	# NOTE: If you are using the test app id, you will need to apply a filter on your game name
	# Otherwise, it may not show up in the lobby list of your clients
	#Steam.addRequestLobbyListStringFilter("name", LOBBY_NAME, Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()
