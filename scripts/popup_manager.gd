extends Node

const ERROR_POPUP_SCENE: PackedScene = preload("res://scenes/components/error_popup/error_popup.tscn")

# Show the popup and wait for its 'popup_closed' signal
func show_error(message: String, code: String = "", title: String = "Error"):
	var popup_instance = ERROR_POPUP_SCENE.instantiate()
	
	# Pass parameters to the popup
	popup_instance.error_title = title
	popup_instance.error_code = code
	popup_instance.error_message = message
	
	# Add it to the scene tree
	get_tree().root.add_child(popup_instance)
	
	# Yield/await the popup's "popup_closed" signal:
	return await popup_instance.popup_closed
