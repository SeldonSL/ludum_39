extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var vehicle = null
var prev_acc = null
var prev_vel = null
export var action = 'nitro'

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	vehicle = get_parent()
	prev_acc = vehicle.acceleration
	prev_vel = vehicle.max_forward_velocity
	
	set_process_input(true)
	
func _input(event):
	if(event.type == Input.is_action_pressed(action) and get_node('Timer').get_time_left() == 0):
		fire_nitro()
		get_parent().get_parent().get_node("sound").play("nitro")

func fire_nitro():
	prev_acc = vehicle.acceleration
	prev_vel = vehicle.max_forward_velocity
	vehicle.acceleration *= 2
	vehicle.max_forward_velocity *= 2
	get_node('Timer').start()
	get_node('smoke').set_emitting(true)
	get_parent().power -= 5


func _on_Timer_timeout():

	vehicle.acceleration = prev_acc
	vehicle.max_forward_velocity = prev_vel
	get_node('Timer').stop()
	get_node('smoke').set_emitting(false)


