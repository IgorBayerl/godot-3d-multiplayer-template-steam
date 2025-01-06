extends Control

const GAME_SCENE = "res://scenes/game.tscn"

@onready var lobbies: ScrollContainer = %Lobbies
@onready var refresh_lobbies: Button = %RefreshLobbies
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
	%Exit.pressed.connect(_on_exit_pressed)
	%HostGame.pressed.connect(_on_host_game_pressed)
	%JoinGame.pressed.connect(_on_join_game_pressed)
	switch_network_button.pressed.connect(_on_switch_network_pressed)
	switch_network_button.text = "Use Steam"
	
	refresh_lobbies.pressed.connect(_on_refresh_lobbies_pressed)

	NetworkManager.network_changed.connect(_on_network_changed)

	refresh_lobbies.hide()
	lobbies.hide()

# Callback for the Exit button
func _on_exit_pressed():
	get_tree().quit(0)

# Callback for the Host Game button
func _on_host_game_pressed():
	NetworkManager.host_game()
	get_tree().call_deferred("change_scene_to_packed", preload(GAME_SCENE))

# Callback for the Join Game button
func _on_join_game_pressed():
	handle_join_lobby()
	
func _on_refresh_lobbies_pressed():
	req_steam_list_lobbies()

func _on_network_changed() -> void:
	# Steam
	if(NetworkManager.active_network_type == NetworkManager.MULTIPLAYER_NETWORK_TYPE.STEAM):
		SteamManager.initialize_steam()
		lobbies.show()
		refresh_lobbies.show()
		Steam.lobby_match_list.connect(_on_lobby_match_list)
		switch_network_button.text = "Use ENet"
		req_steam_list_lobbies()
		return
	#ENet
	if(NetworkManager.active_network_type == NetworkManager.MULTIPLAYER_NETWORK_TYPE.ENET):
		lobbies.hide()
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
	
#TODO Move this to a steam related class instead of main menu
func _on_lobby_match_list(lobbies_list: Array):
	# Clear the current list of lobbies
	for lobby_child in $"Menu/Lobbies/VBoxContainer".get_children():
		lobby_child.queue_free()
		
	for lobby in lobbies_list:
		var lobby_name: String = Steam.getLobbyData(lobby, "name")
		
		if lobby_name != "":
			var lobby_mode: String = Steam.getLobbyData(lobby, "mode")
			var num_of_members: int = Steam.getNumLobbyMembers(lobby)
			
			var lobby_button: Button = Button.new()
			lobby_button.set_text(str(num_of_members) + " | " + lobby_name + " | " + lobby_mode)
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
	print(">>> Join lobby %s" % lobby_id)
	SignalBus.lobby_joined.connect(_on_joined_lobby)
	NetworkManager.join_game(lobby_id)
	
func _on_joined_lobby(lobby_id: int):
	SignalBus.lobby_joined.disconnect(_on_joined_lobby)
	get_lobby_members(lobby_id)
	# TODO: after joining the lobby, we want to get the information of the other people in the same lobby and display somewhere
	get_tree().call_deferred("change_scene_to_packed", preload(GAME_SCENE))

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
func list_friends_with_the_game(_lobbies: Array):
	pass
	
	

const PACKET_READ_LIMIT: int = 32

var lobby_data
#var lobby_id: int = 0
var lobby_members: Array = []
var lobby_members_max: int = 10
var lobby_vote_kick: bool = false
var steam_id: int = 0
var steam_username: String = ""


func get_lobby_members(lobby_id: int) -> void:
	print("Geting lobby members...")
	# Clear your previous lobby list
	lobby_members.clear()

	# Get the number of members from this lobby from Steam
	var num_of_members: int = Steam.getNumLobbyMembers(lobby_id)

	# Get the data of these players from Steam
	for this_member in range(0, num_of_members):
		# Get the member's Steam ID
		var member_steam_id: int = Steam.getLobbyMemberByIndex(lobby_id, this_member)
		#if member_steam_id == 0:
			#continue
		# Get the member's Steam name
		var member_steam_name: String = Steam.getFriendPersonaName(member_steam_id)
		print("here %s" % member_steam_name)

		# Add them to the list
		lobby_members.append({"steam_id":member_steam_id, "steam_name":member_steam_name})
	print(">>> LOBBY MEMBERS --> %s" % lobby_members)
