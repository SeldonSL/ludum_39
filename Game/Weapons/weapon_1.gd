extends Node2D

var weaponReady = true
var angle_noise =  [-3.14159/100, 0, 3.14159/100]
var angle_noise_index = 0
var bullet = preload("res://Game/Weapons/bullet_1.tscn")

func _ready():
	set_process_input(true)
	
func fire_weapon():
	var norm_vect = (get_global_pos()- get_node("dir").get_global_pos()).normalized()
	var angle = 3*PI/2-atan2(norm_vect.x, norm_vect.y)

	
	if (weaponReady):
		get_parent().power -= 1
 		# create bullet node
		var b = bullet.instance()
		b.set_rot(3*PI/2-angle)
		get_tree().get_root().add_child(b)
		
		# set initial angle
		var dir_angle = Vector2(200 * cos(angle), 200 * sin(angle)) 
		b.set_pos(get_parent().get_global_pos()+ dir_angle)
		b.set_angle(angle + angle_noise[angle_noise_index % 3])
		angle_noise_index += 1
		if (angle_noise_index == 9):
			angle_noise_index == 0
		
		# reset timer for next bullet
		weaponReady = false
		get_node("Timer").start()

	
func _on_Timer_timeout():
	weaponReady = true

func _input(event):
		if(event.type == Input.is_action_pressed('shoot')):
			fire_weapon()

