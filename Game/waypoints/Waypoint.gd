extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var Number = 0
export var Last = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_Waypoint_body_enter( body ):
	if body.is_in_group('enemies'):
		var enemy = body
		if Last:
			enemy._current_waypoint = 0
		else:
			enemy._current_waypoint += 1

