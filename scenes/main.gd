extends Node

@export var mob_scene: PackedScene
var score

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func game_over():
	pass # Replace with function body.
	$Score_timer.stop()
	$Mobs_timer.stop()
	
func new_game():
	score = 0
	$Player.start($Start_position.position)
	$Start_timer

func _on_start_timer_timeout():
	$Mobs_timer.start()
	$Score_timer.start()

func _on_score_timer_timeout():
	score += 1

func _on_mobs_timer_timeout():
	var mob = mob_scene.instantiate()
	
	var mob_spawn_location = get_node("Mob_path/Mob_spawn_location")
	mob_spawn_location.progress_ratio = randf()
	
	var direction = mob_spawn_location.rotation + PI / 2
	
	mob.position = mob_spawn_location
	
	var velocity = Vector2(randf_range(150.0, 250.0), 0)
	mob.linear_velocity = velocity.rotated((direction))
	
	add_child(mob)
