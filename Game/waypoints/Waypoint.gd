extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var Number = 0
export var Last = false
var pos = 0
var laps_first = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_Waypoint_body_enter( body ):
	if body.is_in_group('enemies') or body.is_in_group('players'):
		var enemy = body
		if Last:
			if enemy._current_waypoint == Number:
				enemy._current_waypoint = 0
				enemy.laps += 1
				if enemy.laps > laps_first:
					laps_first += 1
					pos = 1
				if enemy.laps == laps_first:
					pos += 1
				print("Pos", pos)
				if body.is_in_group('players'):
					body.pos = pos

					print("pos", pos)
		else:
			if enemy._current_waypoint == Number:
				enemy._current_waypoint += 1
