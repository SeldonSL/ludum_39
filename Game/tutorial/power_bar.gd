extends TextureProgress

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var player = get_parent().get_parent().get_node("PlayerCar")
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	pass

func _process(delta):
	set_value(player.power)