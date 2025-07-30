extends CharacterBody2D
@onready var state_label = $StateLabel
#The state of my character
enum States {
	Walk,
	Dash,
	Jump,
	fall,
	Idle,
	Dashend
}

@export var currentState = States.Idle

#grav and spd
@export var movespeed = 160
var movedir : Vector2
@export var gravity = 2100
const dashspd = 700
const termvelocity : float = 650

#jumping
@export var jumpvel = 0
const jumpdecel = 0.4
var hasjump = 2
var isjumping = false


#Dashing
var isdashing = false
var dashtimer = 0.0
const dashtime = 0.25
const dashmult = 2
var dashdir : Vector2 = Vector2.ZERO
var lastdir : Vector2 = Vector2.ZERO
const dashcdtime = 0.4
var dashcd = 0
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var camera = $Camera2D


func _physics_process(delta):
	handle_state_transitions()
	perform_state_actions(delta)
	move_and_slide()
	
	if dashcd > 0 and is_on_floor():
		dashcd -= delta
		
	if velocity.y >= 1300:
		velocity.y = termvelocity

	state_label.text = States.keys()[currentState]
	print(dashcd)

func handle_state_transitions():
	
	if hasjump == 2:
		jumpvel = -460
	elif hasjump == 1:
		jumpvel = -420
	
		
	if Input.is_action_just_pressed("ui_left"):
		lastdir = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_right"):
		lastdir = Vector2.RIGHT
		
	
	
	if is_on_floor():
		isjumping = false
		hasjump = 2
	if not is_on_floor() and isjumping == false:
		hasjump = 1
	
		
	if Input.is_action_just_pressed("dash") and not isdashing and dashcd <= 0:
		currentState = States.Dash
		dashtimer = dashtime
		hasjump = 0
		isdashing = true
		dashcd = dashcdtime
		dashdir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if dashdir == Vector2.ZERO:
			dashdir = lastdir
	if isdashing:
		return
	
	if Input.is_action_just_pressed("ui_accept") and hasjump > 0:
		currentState = States.Jump
		isjumping = true
		hasjump -= 1
		dashcd = 0
		velocity.y = jumpvel
		return
	if Input.is_action_just_released("ui_accept"):
		velocity.y *= jumpdecel
	elif isjumping and velocity.y < 0:
		currentState = States.Jump
	elif not is_on_floor() and velocity.y > 0:
		currentState = States.fall
	elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		currentState = States.Walk
	else:
		currentState = States.Idle

			
func perform_state_actions(delta):
	match currentState:
		States.Walk:
			movedir.x = Input.get_axis("ui_left", "ui_right")
			
			velocity.x = movedir.x * movespeed
			#if velocity.x == 0:
				#return
			if Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
				animated_sprite_2d.scale.x = -1
				animated_sprite_2d.play("Walking")
			elif Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left"):
				animated_sprite_2d.scale.x = 1
				animated_sprite_2d.play("Walking")
			elif Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left"):
				animated_sprite_2d.play("Idle")
			if not is_on_floor():
				velocity.y += gravity * delta
			else:
				velocity.y = 0
			
		States.Idle:
			velocity.x = 0
			if lastdir == Vector2.LEFT:
				animated_sprite_2d.scale.x = -1
				animated_sprite_2d.play("Idle")
			elif lastdir == Vector2.RIGHT:
				animated_sprite_2d.scale.x = 1
				animated_sprite_2d.play("Idle")
			elif lastdir == Vector2.ZERO:
				animated_sprite_2d.play("Idle")
				
			
			if not is_on_floor():
				velocity.y += gravity * delta
			else:
				velocity.y = 0
		
		States.Jump:
			movedir.x = Input.get_axis("ui_left", "ui_right")
			if Input.is_action_pressed("ui_left") and Input.is_action_just_pressed("ui_accept"):
				animated_sprite_2d.scale.x = -1
				animated_sprite_2d.play("Jump")
			elif Input.is_action_pressed("ui_right") and Input.is_action_just_pressed("ui_accept"):
				animated_sprite_2d.scale.x = 1
				animated_sprite_2d.play("Jump")
			elif not Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left") and Input.is_action_just_pressed("ui_accept"):
				if lastdir == Vector2.RIGHT:
					animated_sprite_2d.scale.x = 1
					animated_sprite_2d.play("Jump")
				if lastdir == Vector2.LEFT:
					animated_sprite_2d.scale.x = -1
					animated_sprite_2d.play("Jump")
				if lastdir == Vector2.ZERO:
					animated_sprite_2d.scale.x = 1
					animated_sprite_2d.play("Jump")
					
					
				
			velocity.x = movedir.x * movespeed
			velocity.y += gravity * delta
		
		States.fall:
			velocity.y += 2100 * delta
			movedir.x = Input.get_axis("ui_left", "ui_right")
			if Input.is_action_pressed("ui_left"):
				animated_sprite_2d.scale.x = -1
				animated_sprite_2d.play("Fall")
			elif Input.is_action_pressed("ui_right"):
				animated_sprite_2d.scale.x = 1
				animated_sprite_2d.play("Fall")
			elif not Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left"):
				if lastdir == Vector2.RIGHT:
					animated_sprite_2d.scale.x = 1
					animated_sprite_2d.play("Fall")
				if lastdir == Vector2.LEFT:
					animated_sprite_2d.scale.x = -1
					animated_sprite_2d.play("Fall")
				if lastdir == Vector2.ZERO:
					animated_sprite_2d.scale.x = 1
					animated_sprite_2d.play("Fall")
			velocity.x = movedir.x * movespeed
			
		
		States.Dash:
			if isdashing == true:
				if Input.is_action_pressed("ui_right") and Input.is_action_just_pressed("dash"):
					animated_sprite_2d.scale.x = 1
				if Input.is_action_pressed("ui_left") and Input.is_action_just_pressed("dash"):
					animated_sprite_2d.scale.x = -1
				if not Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right") and Input.is_action_just_pressed("dash"):
					if lastdir == Vector2.LEFT:
						animated_sprite_2d.scale.x = -1
					if lastdir == Vector2.RIGHT:
						animated_sprite_2d.scale.x = 1
					if lastdir == Vector2.ZERO:
						lastdir = Vector2.RIGHT
			animated_sprite_2d.play("Dash")
			if dashtimer > 0:
				velocity = dashdir.normalized() * 420
				if dashdir.y < 0 and velocity.y < -400:
					velocity.y = -400
				dashtimer -= delta
				if dashdir.y > 0 and velocity.y > 420:
					velocity.y = 420
				dashtimer -= delta
			else:
				isdashing = false
				velocity = velocity.move_toward(Vector2.ZERO, 15000 * delta)
				currentState = States.Idle
			
			
				
			
			
			
		
	
	
	
	
