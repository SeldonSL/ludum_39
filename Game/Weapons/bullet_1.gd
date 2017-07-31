extends Area2D

export var Speed = 1000
var angle = Vector2(0,0)

func _ready():
	set_fixed_process(true)


func _fixed_process(delta):

	var pos = self.get_pos()


	pos += Vector2(cos(angle) * Speed * delta, sin(angle) * Speed * delta)	
	self.set_pos(pos)

		
func set_angle(angle_in):	
	angle = angle_in


func _on_Timer_timeout():
	self.queue_free()
	

func _on_Bullet_body_enter( body ):
	if body.has_method("add_damage"):
		body.add_damage(1)
	self.queue_free() 


func _on_Bullet_area_enter( area ):
	if area.has_method("add_damage"):
		area.add_damage(1)
	self.queue_free() 
