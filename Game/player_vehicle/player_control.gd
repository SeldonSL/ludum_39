extends RigidBody2D

# ---------------------------------------------------------
# QUICK HOW-TO:
# - Make your changes in the Editor by selecting the Node
# - Add Input Map for all input strings in the Editor
# - NB: If you do not use Joystick Left/Right Triggers update Input code.
# - NB: If you do not use Left Joystick update Input code.
# ---------------------------------------------------------

# Input Map Strings - Must be set in Project Settings
export (String) var input_steer_left = "left"
export (String) var input_steer_right = "right"
export (String) var input_accelerate = "acc"
export (String) var input_break = "break"

# Joystick Deadzone Thresholds
var stick_min = 0.07 # If the axis is smaller, behave as if it were 0

# Driving Properties
export (int) var acceleration = 18 
export (int) var max_forward_velocity = 2000
export (float, 0, 1, 0.001) var drag_coefficient = 0.99 # Recommended: 0.99 - Affects how fast you slow down
export (float, 0, 10, 0.01) var steering_torque = 3.75 # Affects turning speed
export (float, 0, 20, 0.1) var steering_damp = 8 # 7 - Affects how fast the torque slows down

# Drifting & Tire Friction
export (bool) var can_drift = true
export (float, 0, 1, 0.001) var wheel_grip_sticky = 0.85 # Default drift coef (will stick to road, most of the time)
export (float, 0, 1, 0.001) var wheel_grip_slippery = 0.99 # Affects how much you "slide"
export (int) var drift_extremum = 250 # Right velocity higher than this will cause you to slide
export (int) var drift_asymptote = 20 # During a slide you need to reduce right velocity to this to gain control
var _drift_factor = wheel_grip_sticky # Determines how much (or little) your vehicle drifts

# Vehicle velocity
var _velocity = Vector2(0, 0)

export var max_power = 100
export var max_damage = 10
var damage = 0
var power= 100
export var power_rate = 0.1
var frozen = false
var laps = 0
var _current_waypoint  = 0
var pos = 0
var engine_sound = -1
# Start
func _ready():
	# Top Down Physics
	set_gravity_scale(0.0)
	
	# Added steering_damp since it may not be obvious at first glance that
	# you can simply change angular_damp to get the same effect
	set_angular_damp(steering_damp)
	
	set_fixed_process(true)

	
func _fixed_process(delta):
	if Input.is_action_pressed(input_accelerate):
		power -= delta * power_rate

	
# Fixed Process
func _integrate_forces(state):
	if frozen:
		get_node("Sprite").set_modulate(Color(0.3,0.3,0.3))
		return
	get_node("Sprite").set_modulate(Color(1,1,1))
	# Drag (0 means we will never slow down ever. Like being in space.)	
	_velocity *= drag_coefficient
	var collision_torque = 0
	for i in range(state.get_contact_count()):
			var dp = state.get_contact_local_normal(i)
			var cc = state.get_contact_collider_object(i)
			
			if (cc):
				_velocity+=state.get_contact_local_normal(i)*300
				#state.set_angular_velocity(sign(dp.x)*10.0)

				break
	
	# If we can drift
	if(can_drift):
		# If we are sticking to the road
		if(_drift_factor == wheel_grip_sticky):
			# If we exceed max stick velocity, begin sliding on the road
			if(get_right_velocity().length() > drift_extremum):
				_drift_factor = wheel_grip_slippery
				# print("SLIDING!")
		# If we are sliding on the road
		else:
			# If our side velocity is less than the drift asymptote, begin sticking to the road
			if(get_right_velocity().length() < drift_asymptote):
				_drift_factor = wheel_grip_sticky
				# print("STICKING!")

	# Add drift to velocity
	_velocity = get_up_velocity() + (get_right_velocity() * _drift_factor)

	# Accelerate
	if(Input.is_action_pressed(input_accelerate)):
		# TODO: Find a better way to handle this instead of hard-coding the check for Triggers
		var axis = Input.get_joy_axis(0, 7) # Right Trigger
		if(axis == 0):
			axis = 1 # Set it to 1 since we are not using the trigger
		
		_velocity += get_up() * acceleration * axis
	# Break / Reverse
	elif(Input.is_action_pressed(input_break)):
		# TODO: Find a better way to handle this instead of hard-coding the check for Triggers
		var axis = Input.get_joy_axis(0, 6) # Left Trigger
		if(axis == 0): 
			axis = 1 # Set it to 1 since we are not using the trigger
		
		_velocity -= get_up() * acceleration * axis

	# Prevent exceeding max velocity
	# 
	# This is done by getting a Vector2 that points up 
	# (the vehicle's default forward direction),
	# and rotate it to the same amount our vehicle is rotated.
	# Then we keep the magnitude of that direction which allows
	# us to calculate the max allowed velocity in that direction.
	var max_speed = (Vector2(0, -1) * max_forward_velocity).rotated(get_rot())
	var x = clamp(_velocity.x, -abs(max_speed.x), abs(max_speed.x))
	var y = clamp(_velocity.y, -abs(max_speed.y), abs(max_speed.y))
	_velocity = Vector2(x, y)
	
	# Torque depends that the vehicle is moving
	var torque = lerp(0, steering_torque, _velocity.length() / max_forward_velocity)
	
	# Steer Left
	if(Input.is_action_pressed(input_steer_left)):
		# TODO: Find a better way to handle this instead of hard-coding the check for Left Stick Axis
		var axis = Input.get_joy_axis(0, 0) # Left Stick Axis
		if(axis < stick_min):
			axis = 1 # Set it to 1 since we are not using the left stick
		
		state.set_angular_velocity(-torque * abs(axis))	
	# Steer Right
	elif(Input.is_action_pressed(input_steer_right)):
		# TODO: Find a better way to handle this instead of hard-coding the check for Left Stick Axis
		var axis = Input.get_joy_axis(0, 0) # Left Stick Axis
		if(axis < stick_min):
			axis = 1 # Set it to 1 since we are not using the left stick
		
		state.set_angular_velocity(torque * abs(axis))
	
	# Apply the force
	state.set_linear_velocity(_velocity)


# Returns up direction (vehicle's forward direction)
func get_up():
	return Vector2(cos(get_rot() + PI/2.0), sin(get_rot() - PI/2.0))

# Returns right direction
func get_right():
	return Vector2(cos(get_rot()), sin(-get_rot()))

# Returns up velocity (vehicle's forward velocity)
func get_up_velocity():
	return get_up() * _velocity.dot(get_up())

# Returns right velocity
func get_right_velocity():
	return get_right() * _velocity.dot(get_right())
	
func add_damage(damage):
	if get_node("destroy").get_time_left() == 0:
		frozen = true
		get_node("destroy").start()

func _on_destroy_timeout():
		frozen = false
