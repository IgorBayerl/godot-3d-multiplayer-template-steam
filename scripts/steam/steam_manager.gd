extends Node
# Singleton

var is_owned: bool = false
var steam_app_id: int = 480
var steam_id: int = 0
var steam_username: String = ""

var lobby_id = 0
var lobby_max_members = 4

func _init() -> void:
	print("Init Steam...")
	OS.set_environment("SteamAppId", str(steam_app_id))
	OS.set_environment("SteamGameId", str(steam_app_id))

func _process(delta: float) -> void:
	Steam.run_callbacks()


func initialize_steam() -> void:
	var initialize_response: Dictionary = Steam.steamInitEx()
	print("Did Steam initialize?: %s" % initialize_response)
	
	if initialize_response['status'] > 0:
		# Get the failure reason
		var FAIL_REASON: String
		match initialize_response['status']:
			1:  FAIL_REASON = "Unknown error."
			2:  FAIL_REASON = "We cannot connect to Steam, steam probably isn't running."
			3:  FAIL_REASON = "Steam client appears to be out of date."
			
		var message = "Failed to initialize Steam!\n%s\nReturning to LAN mode" % FAIL_REASON
		await PopupManager.show_error(message, str(initialize_response['status']), "Oops")
		#get_tree().quit()
		NetworkManager.set_network(NetworkManager.MULTIPLAYER_NETWORK_TYPE.ENET)
		return
	
	is_owned = Steam.isSubscribed()
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	
	print("steam_id : %s" % steam_id)
	
	if not is_owned:
		print("User does not own the game!")
		await PopupManager.show_error("User does not own the game!", "0", "Oops")
		get_tree().quit()
