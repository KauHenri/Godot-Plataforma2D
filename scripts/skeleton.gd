extends CharacterBody2D

enum SkeletonState{
	walk,
	dead
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var clear_timer: Timer = $ClearTimer

const SPEED = 10.0
const JUMP_VELOCITY = -400.0

var status: SkeletonState

var direction = 1

func _ready() -> void:
	go_to_walk_state()

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		SkeletonState.walk:
			walk_state(delta)
		SkeletonState.dead:
			dead_state(delta)

	move_and_slide()

func go_to_walk_state():
	status = SkeletonState.walk
	anim.play("walk")
	
func go_to_dead_state():
	status = SkeletonState.dead
	anim.play("dead")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	clear_timer.start()

func walk_state(_delta):
	velocity.x = SPEED * direction
	
	if wall_detector.is_colliding():
		scale.x *= -1
		direction *= -1
	
	if not ground_detector.is_colliding():
		scale.x *= -1
		direction *= -1
	
func dead_state(_delta):
	pass

func take_damage():
	go_to_dead_state()

func _on_clear_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0) # 1 segundo para sumir
	tween.finished.connect(queue_free)
