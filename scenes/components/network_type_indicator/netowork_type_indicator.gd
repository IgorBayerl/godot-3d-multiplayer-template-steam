extends Control

@onready var label: Label = %Label

func _ready() -> void:
	label.text = NetworkManager.get_active_network_type_string()
	NetworkManager.connect("network_changed",_on_network_changed)

func _on_network_changed() -> void:
	label.text = NetworkManager.get_active_network_type_string()
