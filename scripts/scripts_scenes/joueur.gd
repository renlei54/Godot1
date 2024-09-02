extends Area2D

# Variable globales 
@onready var noms_collision_layers = $Noms_collision_layers.noms_collision_layers
# Bloquages
var bloquage_input = false
var bloquage_rotation = false
var bloquage_deplacement = false
# Statistiques du joueur
@export var vitesse = 400
@export var vie = 100
@export var vie_max = 100
@export var degats = 50
@export var direction = Vector2.ZERO
var orientation
# Actions du joueur
var input_deplacement_droite = false
var input_deplacement_gauche = false
var input_deplacement_haut = false
var input_deplacement_bas = false
var input_attaque = false
var input_verrouillage = false
var input_roulade = false
# Taille de l'écran
@onready var screen_size = get_viewport_rect().size
# Noeuds
@onready var mob = $/root/Main/Mob
@onready var animations = $Animations
@onready var composant_degats = $Composant_degats 
# Signaux
signal modification_vie(nouvelle_valeur_vie)

func _ready():
	
	# Désactivation des collisions de l'attaque
	$Attaque/Collisions_attaque.disabled = true
	$Collisions_joueur.disabled = false
	$Spritesheet_marche.visible = true
	
	hide()

func _process(delta):

	# Lecture des inputs
	input_deplacement_droite = false
	input_deplacement_gauche = false
	input_deplacement_haut = false
	input_deplacement_bas = false
	input_attaque = false
	input_verrouillage = false
	input_roulade = false
	if not bloquage_input:
		input_deplacement_droite = Input.is_action_pressed("Deplacement_droite")
		input_deplacement_gauche = Input.is_action_pressed("Deplacement_gauche")
		input_deplacement_haut = Input.is_action_pressed("Deplacement_haut")
		input_deplacement_bas = Input.is_action_pressed("Deplacement_bas")
		input_attaque = Input.is_action_just_pressed("Attaque")
		input_verrouillage = Input.is_action_just_pressed("Verrouillage")
		input_roulade = Input.is_action_just_pressed("Roulade")
		
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
	
	# Orientation du joeur en fonction du vecteur direction
	if direction.y > 0:
		animations.play("Marche_bas")
		orientation = "bas"
	elif direction.x > 0:
		animations.play("Marche_droite")
		orientation = "droite"
	elif direction.x < 0:
		animations.play("Marche_gauche")
		orientation = "gauche"
	elif direction.y < 0:
		animations.play("Marche_haut")
		orientation = "haut"

	# Attaque 
	if input_attaque:
		animations.play("Attaque")
		bloquage_input = true

	# Verrouillage
	if input_verrouillage:
		bloquage_rotation = not bloquage_rotation

	# Roulade
	if input_roulade:
		animations.play("Roulade")
		bloquage_input = true

	# Rotation du joueur si le personnage est en mouvement
	if not bloquage_rotation and direction.length() > 0:
		$Attaque.rotation_degrees = rad_to_deg(direction.angle())

	# Si la rotation est bloquée (verrouillage en cours)
	if bloquage_rotation:
		verrouillage()

	# Modification de la position du joueur 
	position += direction.normalized() * delta * vitesse
	
	# Vérification de sortie de l'écran
	position = position.clamp(Vector2.ZERO, screen_size)

# Fonction d'affichage du personnage
func start(pause):
	position = pause
	show()

# Fonction de verrouillage
func verrouillage():
			# Vérifictaion de la présence d'un ennemi
		if has_node("/root/Main/Mob"):
			$Attaque.rotation_degrees = rad_to_deg(position.angle_to_point(mob.position))
		# Dévérouillage s'il n'y a plus d'ennemis
		else:
			bloquage_rotation = not bloquage_rotation

 # Fonction de fin d'animation
func _on_animations_animation_finished(_anim_name):
		# Si les inputs sont bloqués
	if bloquage_input:
		bloquage_input = false

# En cas de collision
func _on_area_entered(area):
	# Si c'est avec un ennemi
	if area.collision_layer == noms_collision_layers["Mob"]:
		# Prise de dégats
		composant_degats.prise_de_degats(self, vie, mob.degats)

# En cas de dégats 
func _on_composant_degats_degats_pris(vie_actuelle):
	# Actualisation de la vie
	vie = vie_actuelle
	# Emmision d'un signal (nottament pour le HUD)
	emit_signal("modification_vie", vie)
