extends CharacterBody2D

# Variables globales
var direction
# Statistiques mob
@onready var vie = $Vie_mob
@export var degats = 20
@export var vie_max = 100
@export var vitesse = 100
@export var vitesse_max = 100
# Noeuds
@onready var joueur = $/root/Main/Joueur
@onready var composant_degats = $Composant_degats
@onready var navigation_agent = $Navigation_agent
@onready var animations = $Animations
@onready var attaque = $Attaque
@onready var collision_attaque = $Attaque/Demi_cercle

func _ready():
	# Initialisation de la vie du mob
	vie.value = vie_max
	collision_attaque.disabled = true

func _physics_process(delta):
	# Suivi du chemin le plus court pour se rendre au joueur
	if has_node("/root/Main/Joueur"): # and global_position.distance_to(joueur.global_position) > 100:
		# Si le joueur est proche
		if global_position.distance_to(joueur.global_position) <= 20:
			attaque.rotation = position.angle_to_point(joueur.position)
			animations.play("Attaque")
		else:
			direction = to_local(navigation_agent.get_next_path_position()).normalized()
			translate(direction * vitesse * delta)
	move_and_slide()
	

# Définition de la cible
func _on_navigation_timer_timeout():
	if has_node("/root/Main/Joueur"):
		navigation_agent.target_position = joueur.global_position

# En cas de dégats
func _on_composant_degats_degats_pris(vie_actuelle):
	# Actualisation de la vie
	vie.value = vie_actuelle

# En cas de détection
func _on_detection_area_entered(area):
	# Si c'est avec un arme
	if area.is_in_group("arme"):
		# Prise de dégats
		composant_degats.prise_de_degats(self, vie.value, joueur.degats)

# Fonction de fin d'animation
func _on_animations_animation_finished(anim_name):
	# Réinitialisation de la vitesse
	if vitesse != vitesse_max:
		vitesse = vitesse_max
		
