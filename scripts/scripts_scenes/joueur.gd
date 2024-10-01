extends CharacterBody2D

# Variable globales 
@onready var regeneration_en_cours = false
@export var direction = Vector2.ZERO
var orientation
var noeuds_visibles = []
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
var input_ciblage_droite = false
var input_ciblage_gauche = false
var input_ciblage_haut = false
var input_ciblage_bas = false
# Noeuds
@onready var mobs = []
@onready var mobs_positions_x = []
@onready var mobs_positions_y = []
@onready var mob_cible 
@onready var mob_distance
@onready var cible_position
@onready var animations = $Animations
@onready var composant_degats = $Composant_degats 
@onready var attaque = $Attaque
@onready var timer_regeneration = $Timer_regenaration
@onready var champ_de_vision = $Champ_de_vision
@onready var main = get_parent()
@onready var viseur = $Viseur
# Signaux
signal modification_vie(nouvelle_valeur_vie)
signal modification_endurance(nouvelle_valeur_endurance)
signal modification_nombre_potions_vie(nouveau_nombre_potions_vie)

func _ready():

	# Désactivation des collisions de l'attaque
	$Attaque/Collisions_attaque.disabled = true
	$Detection/Collisions_detection.disabled = false
	$Spritesheet_marche.visible = true
	viseur.visible = false
	
	hide()
	
	main.connect("suppression_entite", Callable(self, "_lorsque_suppression_entite"))
	
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
	input_ciblage_droite = false
	input_ciblage_gauche = false
	input_ciblage_haut = false
	input_ciblage_bas = false
	if not bloquage_input:
		input_deplacement_droite = Input.is_action_pressed("Deplacement_droite")
		input_deplacement_gauche = Input.is_action_pressed("Deplacement_gauche")
		input_deplacement_haut = Input.is_action_pressed("Deplacement_haut")
		input_deplacement_bas = Input.is_action_pressed("Deplacement_bas")
		input_attaque = Input.is_action_just_pressed("Attaque")
		input_verrouillage = Input.is_action_just_pressed("Verrouillage")
		input_roulade = Input.is_action_just_pressed("Roulade")
		input_potion_vie = Input.is_action_just_pressed("Potion_vie")
		input_ciblage_droite = Input.is_action_just_pressed("Ciblage_droite")
		input_ciblage_gauche = Input.is_action_just_pressed("Ciblage_gauche")
		input_ciblage_haut = Input.is_action_just_pressed("Ciblage_haut")
		input_ciblage_bas = Input.is_action_just_pressed("Ciblage_bas")
		
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
		if bloquage_rotation:
			viseur.visible = false
			bloquage_rotation = false
		else:
			viseur.visible = true
			ciblage_mob_proche()
			bloquage_rotation = true

	# Si la rotation est bloquée (verrouillage en cours)
	if bloquage_rotation:
		# Changement de la cible en fonction de la touche appuyée
		if input_ciblage_droite:
			tri_mobs_visibles_positions()
			if (mobs_positions_x.find(mob_cible) + 1) >= 0 and len(mobs_positions_x) > (mobs_positions_x.find(mob_cible) + 1):
				mob_cible = mobs_positions_x[mobs_positions_x.find(mob_cible) + 1]
		if input_ciblage_gauche:
			tri_mobs_visibles_positions()
			if (mobs_positions_x.find(mob_cible) - 1) >= 0 and len(mobs_positions_x) > (mobs_positions_x.find(mob_cible) - 1):
					mob_cible = mobs_positions_x[mobs_positions_x.find(mob_cible) - 1]
		if input_ciblage_haut:
			tri_mobs_visibles_positions()
			if (mobs_positions_y.find(mob_cible) - 1) >= 0 and len(mobs_positions_y) > (mobs_positions_y.find(mob_cible) - 1):
				mob_cible = mobs_positions_y[mobs_positions_y.find(mob_cible) - 1]
		if input_ciblage_bas:
			tri_mobs_visibles_positions()
			if (mobs_positions_y.find(mob_cible) + 1) >= 0 and len(mobs_positions_y) > (mobs_positions_y.find(mob_cible) + 1):
				mob_cible = mobs_positions_y[mobs_positions_y.find(mob_cible) + 1]
		# Verrouillage
		verrouillage(mob_cible, delta)

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
	
	# Champ de vision
	for mob in mobs:
		if mob in noeuds_visibles:
			mob.visible = true
		else:
			mob.visible = false

	# Modification de la position du joueur 
	position += direction.normalized() * delta * vitesse

	# Orientation du champ de vision
	if not bloquage_rotation:
		if direction.length() > 0:
			champ_de_vision.orientation(direction)

	# Gestion des collisions
	move_and_slide()

# Fonction d'affichage du personnage
func start(pause):
	position = pause
	show()

# Fonction de verrouillage
func verrouillage(cible, delta):
	# Si la cible n'est pas morte ou invalide
	if is_instance_valid(cible):
		# Centrage du viseur sur la cible
		viseur.global_position = mob_cible.position - direction.normalized() * vitesse * delta
		# Recherche de la position de la cible
		cible_position = rad_to_deg(position.angle_to_point(cible.position))
		# Orientation du champ de vision
		champ_de_vision.orientation(cible.position - position)
		# Orientation du joueur en fonction de la position de la cible
		if not bloquage_input:
			if cible_position > 45 and cible_position < 135:
				orientation = "bas"
				attaque.rotation_degrees = 90
			elif cible_position < 45 and cible_position > -45:
				orientation = "droite"
				attaque.rotation_degrees = 0
			elif cible_position < -45 and cible_position > -135:
				orientation = "haut"
				attaque.rotation_degrees = -90
			else:
				orientation = "gauche"
				attaque.rotation_degrees = 180
	# Recherche d'une nouvelle cible si la cible actuelle n'est pas valide
	else:
		ciblage_mob_proche()

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
	if body.is_in_group("mob"):
		# Prise de dégats
		composant_degats.prise_de_degats(self, vie, body.degats)

# En cas de collision avec l'arme
func _on_attaque_body_entered(body):
	if body.is_in_group("bloc"):
		animations.seek(0.5, true)
		_on_animations_animation_finished("Attaque")

# Fonction de choix de cible
func ciblage_mob_proche():
	mob_distance = INF
	mob_cible = null

	for noeud in noeuds_visibles:
		if noeud in mobs:
			if global_position.distance_to(noeud.global_position) < mob_distance:
				mob_distance = global_position.distance_to(noeud.global_position)
				mob_cible = noeud

	if mob_cible == null:
		viseur.visible = false
		bloquage_rotation = false

# Fonction de recherche des mobs
func recherche_mobs():
	for entite in main.liste_entites:
		if entite.name.begins_with("Mob"):
			mobs.append(entite)

# Fonction de comparaison pour trier par position.x
func compare_x(a, b):
	return a.position.x < b.position.x
	
# Fonction de comparaison pour trier par position.y
func compare_y(a, b):
	return a.position.y < b.position.y

# Fonction de tri des coordonnées des mobs visibles
func tri_mobs_visibles_positions():

	mobs_positions_x = []
	mobs_positions_y = []

	for noeud in noeuds_visibles:
		if noeud in mobs:
			mobs_positions_x.append(noeud)
			mobs_positions_y.append(noeud)

	mobs_positions_x.sort_custom(compare_x)
	mobs_positions_y.sort_custom(compare_y)

# En cas de suppression d'une entite
func _lorsque_suppression_entite(entite):
	if entite in mobs:
		mobs.erase(entite)
