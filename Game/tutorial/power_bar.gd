extends TextureProgress

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var player = get_parent().get_parent().get_node("PlayerCar")
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	get_tree().set_pause(true)
	get_parent().get_parent().get_node("sound").play("start")
	

func _process(delta):
	set_value(player.power)
	get_parent().get_node("laps").set_text(str(player.laps))
	get_parent().get_node("pos").set_text(str(player.pos))
	if player.power <= 0:
		get_tree().set_pause(true)
		get_parent().get_node("game_over").show()
	if player.laps > 4:
		get_tree().set_pause(true)
		get_parent().get_node("win").show()

func _on_t3_timeout():
	get_parent().get_node("3").hide()
	get_parent().get_node("2").show()
	get_parent().get_node("t2").start()
	get_parent().get_parent().get_node("sound").play("start")
	


func _on_t2_timeout():
	get_parent().get_node("2").hide()
	get_parent().get_node("1").show()
	get_parent().get_node("t1").start()
	get_parent().get_parent().get_node("sound").play("start")


func _on_t1_timeout():
	get_parent().get_node("1").hide()
	get_parent().get_parent().get_node("sound").play("start")
	get_tree().set_pause(false)
