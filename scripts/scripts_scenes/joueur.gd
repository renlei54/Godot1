extends CharacterBody2D

# Variable globales 
@onready var noms_collision_layers = $Noms_collision_layers.noms_collision_layers
@onready var regeneration_en_cours = false
@export var direction = Vector2.ZERO
var orientation
# Bloquages
var bloquage_input = false
var bloquage_rotation = false
var bloquage_direction = false
var bloquage_animations = false
var bloquage_regeneration = false
# Statistiques du joueur
@export var vitesse = 400
@export var vie_max = 100
@export var vie = vie_max
@export var degats = 50
@export var endurance_max = 50
@export var endurance = endurance_max
@export var nombre_potions_vie = 3
@export var efficacite_potions_vie = 40
# Actions du joueur
var input_deplacement_droite = false
var input_deplacement_gauche = false
var input_deplacement_haut = false
var input_deplacement_bas = false
var input_attaque = false
var input_verrouillage = false
var input_roulade = false
var input_potion_vie = false
# Noeuds
@onready var mob = $/root/Main/Mob
@onready var animations = $Animations
@onready var composant_degats = $Composant_degats 
@onready var attaque = $Attaque
@onready var timer_regeneration = $Timer_regenaration
# Signaux
signal modification_vie(nouvelle_valeur_vie)
signal modification_endurance(nouvelle_valeur_endurance)
signal modification_nombre_potions_vie(nouveau_nombre_potions_vie)

func _ready():
	
	# Désactivation des collisions de l'attaque
	$Attaque/Collisions_attaque.disabled = true
	$Detection/Collisions_detection.disabled = false
	$Spritesheet_marche.visible = true
	
	hide()

func _physics_process(delta):

	# Lecture des inputs
	input_deplacement_droite = false
	input_deplacement_gauche = false
	input_deplacement_haut = false
	input_deplacement_bas = false
	input_attaque = false
	input_verrouillage = false
	input_roulade = false
	input_potion_vie = false
	if not bloquage_input:
		input_deplacement_droite = Input.is_action_pressed("Deplacement_droite")
		input_deplacement_gauche = Input.is_action_pressed("Deplacement_gauche")
		input_deplacement_haut = Input.is_action_pressed("Deplacement_haut")
		input_deplacement_bas = Input.is_action_pressed("Deplacement_bas")
		input_attaque = Input.is_action_just_pressed("Attaque")
		input_verrouillage = Input.is_action_just_pressed("Verrouillage")
		input_roulade = Input.is_action_just_pressed("Roulade")
		input_potion_vie = Input.is_action_just_pressed("Potion_vie")
		
		# Lecture de l'animation d'Idle si le joueur ne se déplace pas
		if direction.length() == 0:
			if orientation == "droite":
				animations.play("Idle_droite")
			if orientation == "gauche":
				animations.play("Idle_gauche")
			if orientation == "haut":
				animations.play("Idle_haut")
			if orientation == "bas":
				animations.play("Idle_bas")

	# Orientation du vecteur direction en fonction des Inputs
	# Touches appuyées 
	if not bloquage_direction:
		if input_deplacement_droite and not input_deplacement_gauche:
			direction.x = 1
		if input_deplacement_gauche and not input_deplacement_droite:
			direction.x = -1
		if input_deplacement_haut and not input_deplacement_bas:
			direction.y = -1
		if input_deplacement_bas and not input_deplacement_haut:
			direction.y = 1
		# Touches pas appuyées ou appuyées simultanément
		if (not input_deplacement_gauche and not input_deplacement_droite) or (input_deplacement_gauche and input_deplacement_droite):
			direction.x = 0
		if (not input_deplacement_haut and not input_deplacement_bas) or (input_deplacement_haut and input_deplacement_bas):
			direction.y = 0

	# Rotation du joueur si le personnage est en mouvement
	if not bloquage_rotation and direction.length() > 0:
		if direction.y > 0:
			orientation = "bas"
			attaque.rotation_degrees = 90
		elif direction.x > 0:
			orientation = "droite"
			attaque.rotation_degrees = 0
		elif direction.x < 0:
			orientation = "gauche"
			attaque.rotation_degrees = 180
		elif direction.y < 0:
			orientation = "haut"
			attaque.rotation_degrees = -90
	
	# Lecture de l'animation de marche	
	if not bloquage_animations:
		if direction.length() > 0:
			if orientation == "haut":
				animations.play("Marche_haut")
			if orientation == "bas":
				animations.play("Marche_bas")
			if orientation == "gauche":
				animations.play("Marche_gauche")
			if orientation == "droite":
				animations.play("Marche_droite")

	# Attaque 
	if input_attaque and endurance > 0:
		# Modification de l'endurance
		endurance -= 15
		emit_signal("modification_endurance", endurance)
		# Lecture de l'animation
		animations.play("Attaque")
		bloquage_input = true
		bloquage_regeneration = true

	# Verrouillage
	if input_verrouillage:
		bloquage_rotation = not bloquage_rotation
	# Si la rotation est bloquée (verrouillage en cours)
	if bloquage_rotation:
		verrouillage()

	# Utilisation d'une potion de vie
	if input_potion_vie and nombre_potions_vie > 0 and vie < vie_max:
		animations.play("Potion")
		bloquage_input = true
		bloquage_animations = true

	# Roulade
	if input_roulade and endurance > 0  and direction.length() > 0: 
		# Modification de l'endurance
		endurance -= 15
		emit_signal("modification_endurance", endurance)
		# Lecture de l'animation
		animations.play("Roulade")
		bloquage_input = true
		bloquage_direction = true
		bloquage_animations = true
		bloquage_regeneration = true

	# Regeneration
	if not bloquage_regeneration and endurance < endurance_max:
		# Temps d'inactivité
		if timer_regeneration.is_stopped():
			timer_regeneration.start()
		# Regeneration
		if regeneration_en_cours:
			endurance += 0.5
			emit_signal("modification_endurance", endurance)

	# Modification de la position du joueur 
	position += direction.normalized() * delta * vitesse
	
	# Vérification de sortie de l'écran
	# position = position.clamp(Vector2.ZERO, screen_size)

	# Gestion des collisions
	move_and_slide()

# Fonction d'affichage du personnage
func start(pause):
	position = pause
	show()

# Fonction de verrouillage
func verrouillage():
	# Vérifictaion de la présence d'un ennemi
	if has_node("/root/Main/Mob"):
		var mob_position = rad_to_deg(position.angle_to_point(mob.position))
		if direction.length() > 0 and not bloquage_input:
			if mob_position > 45 and mob_position < 135:
				orientation = "bas"
				attaque.rotation_degrees = 90
			elif mob_position < 45 and mob_position > -45:
				orientation = "droite"
				attaque.rotation_degrees = 0
			elif mob_position < -45 and mob_position > -135:
				orientation = "haut"
				attaque.rotation_degrees = -90
			else:
				orientation = "gauche"
				attaque.rotation_degrees = 180
	# Dévérouillage s'il n'y a plus d'ennemis
	else:
		bloquage_rotation = not bloquage_rotation

 # Fonction de fin d'animation
func _on_animations_animation_finished(_anim_name):
	# Désactivation des bloquages
	if bloquage_input:
		bloquage_input = false
	if bloquage_direction:
		bloquage_direction = false
	if bloquage_animations:
		bloquage_animations = false
	if bloquage_regeneration:
		bloquage_regeneration = false
	# Fin d'animation de potion de vie
	if _anim_name == "Potion":
		# Modification de la vie actuelle
		if vie_max - vie < efficacite_potions_vie:
			vie = vie_max
		else:
			vie += efficacite_potions_vie
		emit_signal("modification_vie", vie)
		# Modification du nombre de potions
		nombre_potions_vie -= 1
		emit_signal("modification_nombre_potions_vie", nombre_potions_vie)

# En cas de dégats 
func _on_composant_degats_degats_pris(vie_actuelle):
	# Actualisation de la vie
	vie = vie_actuelle
	# Emmision d'un signal (nottament pour le HUD)
	emit_signal("modification_vie", vie)

# En cas de regeneration
func _on_timer_regenaration_timeout():
	if not bloquage_regeneration and endurance < endurance_max:
		regeneration_en_cours = true
	else:
		regeneration_en_cours = false

# En cas de détection
func _on_detection_body_entered(body):	
	# Si c'est avec un ennemi
	if body.collision_layer == noms_collision_layers["Mob"]:
		# Prise de dégats
		composant_degats.prise_de_degats(self, vie, mob.degats)
