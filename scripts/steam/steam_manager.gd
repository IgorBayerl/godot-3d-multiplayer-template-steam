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


func initialize_steam():
	var initialize_response: Dictionary = Steam.steamInitEx()
	print("Did Steam initialize?: %s" % initialize_response)
	
	if initialize_response['status'] > 0:
		print("Faild to initialize Steam!, shuting down. %s" % initialize_response)
		#Improve error handling
		get_tree().quit()
	
	is_owned = Steam.isSubscribed()
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	
	print("steam_id : %s" % steam_id)
	
	if not is_owned:
		print("User does not own the game!")
		get_tree().quit()

func disable_steam(): 
	print("Disable steam...")
	pass
