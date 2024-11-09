extends CharacterBody2D

# Variables globales
var direction
# Statistiques mob
@onready var vie = $Vie_mob
@export var degats = 20
@export var vie_max = 100
@export var vitesse = 100
# Noeuds
@onready var joueur = $/root/Main/Joueur
@onready var composant_degats = $Composant_degats
@onready var navigation_agent = $Navigation_agent

func _ready():
	# Initialisation de la vie du mob
	vie.value = vie_max

func _physics_process(delta):
	# Suivi du chemin le plus court pour se rendre au joueur
	direction = to_local(navigation_agent.get_next_path_position()).normalized()
	if has_node("/root/Main/Joueur") and global_position.distance_to(joueur.global_position) > 100:
		position += direction.normalized() * delta * vitesse
	move_and_slide()

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
