extends Object

class_name LobbyConfig # this is used on the lobby item

# Define typed properties for the lobby configuration
var id: int
var capacity: int
var member_count: int
var title: String
var extra_info: String

# Constructor to initialize properties
func _init(id: int = 0, capacity: int = 0, member_count: int = 0, title: String = "", extra_info: String = "") -> void:
	self.id = id
	self.capacity = capacity
	self.member_count = member_count
	self.title = title
	self.extra_info = extra_info
