extends KinematicBody2D

#### Player Properties
var state
var velocity : Vector2 = Vector2()
var lives : int = 3
export (int) var MOVE_SPEED = 200 # 200 pixel / sec
var collide
signal player_hit(current_lives)
signal shoot(player_position, bullet)
signal game_over()
var bullet = preload("res://NormalBullet.tscn")
var can_shoot = true
###################################################
#### Player States
enum states {
	move, dead, hit
}
###################################################

func _ready():
	state = states.move

func _process(delta):
	match state:
		states.move:
			_move(delta)
		states.hit:
			pass
		states.dead:
			pass
			
func _move(delta):
	velocity = Vector2()
	if Input.is_action_pressed("ui_left") and position.x >= 0:
		velocity.x = -1
	if Input.is_action_pressed("ui_right") and position.x <= 400:
		velocity.x = 1
	if Input.is_action_pressed("ui_up") and position.y >= 300:
		velocity.y = -1
	if Input.is_action_pressed("ui_down") and position.y <= 600:
		velocity.y = 1
	if Input.is_action_pressed("ui_accept"):
		if can_shoot:
			print("shoot")
			shoot()
	collide = move_and_collide(velocity * MOVE_SPEED * delta)


func check_collided_object() -> void:
	if collide != null:
		if collide is KinematicBody2D:
			if lives > 0:
				lives -= 1
				emit_signal("player_hit", lives)
				state = states.hit
				$Sprite/AnimationPlayer.play("on_hit")
				yield($Sprite/AnimationPlayer, "animation_finished")
				state = states.move
			else:
				emit_signal("game_over")
				queue_free()

func shoot() -> void:
	can_shoot = false
	emit_signal("shoot",position ,bullet)
	$BulletReload.start()


func _on_BulletReload_timeout():
	can_shoot = true
