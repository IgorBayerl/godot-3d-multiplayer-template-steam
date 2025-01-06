extends CanvasLayer

signal popup_closed

@export var default_error_title: String = "Error"

@onready var ok_button: Button = %OkButton
@onready var title_label: Label = %TitleLabel
@onready var message_label: Label = %MessageLabel

var error_title: String = ""
var error_code: String = ""
var error_message: String = ""

func _ready() -> void:
	# Connect the OK button signal
	ok_button.pressed.connect(_on_ok_button_pressed)
	
	# If no custom title was provided, use the default
	if error_title.strip_edges() == "":
		error_title = default_error_title
	
	# Set the popup title
	title_label.text = error_title
	
	# If error_code is provided, combine it with the message like "code: message"
	if error_code.strip_edges() != "":
		message_label.text = "%s: %s" % [error_code, error_message]
	else:
		message_label.text = error_message

func _on_ok_button_pressed() -> void:
	popup_closed.emit()  # Notify anyone who's waiting
	queue_free()                 # Remove the popup from the scene
