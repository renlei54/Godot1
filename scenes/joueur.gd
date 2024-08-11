extends Area2D

@export var speed = 400
var screen_size
var animation_running = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# taille de l'écran
	screen_size = get_viewport_rect().size
	
	# animation par défaut
	$Animations_personnage.animation = "Walk"
	
	# désactivation des collisions de l'atttaque
	$Collisions_attaque.disabled = true
	
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Vecteur vitesse définie à 0
	var velocity = Vector2.ZERO
	
	# Si une animation importante n'est pas en cours
	if animation_running == false:
		# Incrémentation du vecteur vitesse de 1 dans la direction concernée, définition de l'animation et rotation du joueur
		if Input.is_action_pressed("move_right"):
			$Animations_personnage.animation = "Walk"
			velocity.x += 1
			rotation_degrees = rad_to_deg(velocity.angle())
		if Input.is_action_pressed("move_left"):
			$Animations_personnage.animation = "Walk"
			velocity.x -= 1
			rotation_degrees = rad_to_deg(velocity.angle())
		if Input.is_action_pressed("move_up"):
			$Animations_personnage.animation = "Walk"
			velocity.y -= 1
			rotation_degrees = rad_to_deg(velocity.angle())
		if Input.is_action_pressed("move_down"):
			$Animations_personnage.animation = "Walk"
			velocity.y += 1
			rotation_degrees = rad_to_deg(velocity.angle())
		
		# Attaque 
		if Input.is_action_pressed("Attack"):
			
			# lancement de l'animation d'attaque
			$Animation_attaque.play("Attaque")
			$Animations_personnage.animation = "Attack"
			
			# Activation des collisions de l'attaque
			$Collisions_attaque.disabled = false
			
			# Animation à ne pas interrompre en cours
			animation_running = true
	
	# Adaptation de la taille du vecteur vitesse en fonction de la vitesse du personnage
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	# Lecture de l'animation
	$Animations_personnage.play()
	
	# Actualisation de la position 
	position += velocity * delta
	
	# Vérification de sortie de l'écran
	position = position.clamp(Vector2.ZERO, screen_size)

# fonction d'affichage du personnage
func start(pause):
	position = pause
	show()

 # fonction de fin d'animation
func _on_animated_sprite_2d_animation_finished():
	
	# si une animation à ne pas interrompre est en cours
	if animation_running:
		$Animations_personnage.animation = "Walk"
		animation_running = false
		$Collisions_attaque.disabled = true

