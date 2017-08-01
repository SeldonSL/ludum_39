extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	get_parent().get_node("PlayerCar").power+=0.5*delta
	if get_parent().get_node("PlayerCar").power > get_parent().get_node("PlayerCar").max_power:
		get_parent().get_node("PlayerCar").power = get_parent().get_node("PlayerCar").max_power
	

func _on_solar_body_enter( body ):
	if body.is_in_group("players"):
		set_process(true)


func _on_solar_body_exit( body ):
	if body.is_in_group("players"):
		set_process(false)
