extends Control

# TODO Add a method that filters, and the debounce should activate on every filter interaction

const LOBBY_ITEM = preload("res://scenes/components/lobby_list/lobby_item.tscn")
@onready var lobby_list: VBoxContainer = %LobbyList

@onready var hide_full_servers: CheckBox = %HideFullServers
@onready var name_filter: LineEdit = %NameFilter

const DEBOUNCE_DELAY = 0.5  # Delay in seconds
var debounce_timer: Timer
var search_query: String
var filter_empty_lobby: bool = false

# Called when clicking on Join Lobby, passing the id
var join_lobby_callback: Callable : set = _set_callback

# Define the lobby items property with a setter
var lobby_items: Array[LobbyConfig] = [] : set = _set_lobby_items

func _ready():
	name_filter.text_changed.connect(_on_name_filter_changed)
	hide_full_servers.toggled.connect(_on_hide_full_servers_toggled)
	
	_setup_debounce_for_filter()
	
	lobby_items = []

func _setup_debounce_for_filter():
	# Create a debounce timer
	debounce_timer = Timer.new()
	debounce_timer.one_shot = true
	debounce_timer.wait_time = DEBOUNCE_DELAY
	debounce_timer.timeout.connect(_on_filter_debounce_timeout)
	add_child(debounce_timer)

# Called when lobby_items is updated
func _set_lobby_items(new_lobby_list: Array[LobbyConfig]) -> void:
	lobby_items = new_lobby_list
	_update_list_ui()
	
# Called when lobby_items is updated
func _set_callback(callback: Callable) -> void:
	join_lobby_callback = callback
	_update_list_ui()

# Updates the UI whenever the lobby list changes
func _update_list_ui(filtered_list: Array[LobbyConfig] = []) -> void:
	var items_to_display = lobby_items
	
	if filtered_list.size() > 0 : # check this in other way, the filtered list can be empty
		items_to_display = filtered_list
		
	clear_lobby_items()
	for lobby in items_to_display:
		var new_lobby_item = LOBBY_ITEM.instantiate()
		new_lobby_item.set_data(lobby)
		new_lobby_item.join_callback = join_lobby_callback
		lobby_list.add_child(new_lobby_item)

# Clears all child elements in this container
func clear_lobby_items() -> void:
	for child in lobby_list.get_children():
		child.queue_free()

func _on_hide_full_servers_toggled(value: bool) -> void:
	filter_empty_lobby = value
	_update_filtered_list()

func _update_filtered_list() -> void:
	# Start with all items
	var filtered_items = lobby_items

	# Apply "hide full servers" filter if toggled
	if filter_empty_lobby:
		filtered_items = filtered_items.filter(func(lobby): return lobby.member_count < lobby.capacity)

	# Apply name filter if search query exists
	if search_query.strip_edges() != "":
		filtered_items = filtered_items.filter(func(lobby): return lobby.title.to_lower().find(search_query.to_lower()) != -1)

	# Update the UI with the final filtered list
	_update_list_ui(filtered_items)

func _on_name_filter_changed(new_text: String):
	search_query = new_text
	debounce_timer.start()  # Reset the timer for debounce

func _on_filter_debounce_timeout():
	_update_filtered_list()
	
