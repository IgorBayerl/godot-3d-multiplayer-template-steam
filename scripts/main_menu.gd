extends Control

const GAME_SCENE = "res://scenes/game.tscn"

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

# Callback for the Exit button
func _on_exit_pressed():
	exit_game()

# Callback for the Host Game button
func _on_host_game_pressed():
	host_game()

# Callback for the Join Game button
func _on_join_game_pressed():
	join_game()

func host_game():
	print("Host game pressed")
	NetworkManager.host_game()
	get_tree().call_deferred("change_scene_to_packed", preload(GAME_SCENE))

func join_game():
	print("Join game pressed")
	NetworkManager.join_game()
	get_tree().call_deferred("change_scene_to_packed", preload(GAME_SCENE))

func exit_game():
	get_tree().quit(0)
