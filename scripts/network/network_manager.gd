extends Node
# Autoload

enum MULTIPLAYER_NETWORK_TYPE { ENET, STEAM }
var active_network_type: MULTIPLAYER_NETWORK_TYPE = MULTIPLAYER_NETWORK_TYPE.ENET
var active_network #this will be the steam or enet network handler class

var _enet_network := preload("res://scenes/network/enet_network.tscn")
var _steam_network := preload("res://scenes/network/steam_network.tscn")

var _loading_scene = preload("res://scenes/loading.tscn")
var _active_loading_scene

var lobby_max_members = 4

var is_hosting_game = false

func host_game():
	print("Host game")
	_build_multiplayer_network()
	show_loading()
	is_hosting_game = true
	active_network.host_server()

func join_game():
	print("Join game")
	_build_multiplayer_network()
	show_loading()
	var TODO_lobby_id = 0
	active_network.join_server(TODO_lobby_id)
	
func show_loading():
	print("Show loading")
	_active_loading_scene = _loading_scene.instantiate()
	add_child(_active_loading_scene)
	
func hide_loading():
	print("Hide loading")
	if _active_loading_scene != null:
		remove_child(_active_loading_scene)
		_active_loading_scene.queue_free()

# We need to set if we are using steam or enet, its not possible to use both.
func _build_multiplayer_network():
	print("Setting active_network")
	match active_network_type:
		MULTIPLAYER_NETWORK_TYPE.ENET:
			print("Setting network type to ENet")
			_set_active_network(_enet_network)
			return
		MULTIPLAYER_NETWORK_TYPE.STEAM:
			print("Setting network type to Steam")
			_set_active_network(_steam_network)
			return
		_:
			print("No match for network type!")
			return
	

func _set_active_network(active_network_scene):
	active_network = active_network_scene.instantiate()
	#active_network._players_spawn_node = _players_spawn_node
	# The network manager is a scene added to the project tree
	add_child(active_network)
	
#TODO: Can be called from anywhere, for example in the menu to toggle between steam and ENet
func set_network():
	pass
