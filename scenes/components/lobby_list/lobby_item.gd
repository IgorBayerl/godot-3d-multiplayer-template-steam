extends PanelContainer

# Lobby configuration using the custom type
var lobby_config: LobbyConfig = LobbyConfig.new()

# Called when clicking on Join Lobby, passing the lobbyConfig
var join_callback: Callable

func _ready() -> void:
	%Join.pressed.connect(_on_join_lobby_pressed)

func set_data(new_lobby_config: LobbyConfig) -> void:
	lobby_config = new_lobby_config
	%PlayerCount.text = str(lobby_config.member_count) + " / " + str(lobby_config.capacity)
	%Title.text = lobby_config.title
	%ExtraInfo.text = lobby_config.extra_info

func _on_join_lobby_pressed() -> void:
	print("Join lobby pressed for lobby %d" % lobby_config.id)
	join_callback.call(lobby_config.id)
	if join_callback:
		print("AAAAAAAAAA %d" % lobby_config.id)
		
