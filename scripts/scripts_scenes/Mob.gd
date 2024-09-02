extends Area2D

@export var vie_max = 100

# Variables globales
@onready var noms_collision_layers = $Noms_collision_layers.noms_collision_layers
# Statistiques mob
@onready var vie = $Vie_mob
@export var degats = 20
# Noeuds
@onready var joueur = $/root/Main/Joueur
@onready var collisions_mob = $Collisions_mob
@onready var composant_degats = $Composant_degats

func _ready():
	# Initialisation de la vie du mob
	vie.value = vie_max

# En cas de collision
func _on_area_entered(area):
	# Si c'est avec un arme
	if area.collision_layer == noms_collision_layers["Arme"]:
		# Prise de dégats
		composant_degats.prise_de_degats(self, vie.value, joueur.degats)

# En cas de dégats
func _on_composant_degats_degats_pris(vie_actuelle):
	# Actualisation de la vie
	vie.value = vie_actuelle

