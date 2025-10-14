extends CharacterBody2D 

func _physics_process(delta):
	if Input.is_key_pressed(KEY_UP):
		position.y -= 5
	if Input.is_key_pressed(KEY_DOWN):
		position.y += 5
