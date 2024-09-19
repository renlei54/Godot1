extends Node2D

# Variables globales
var nombre_rayons = 50
var angle_vision = 120
var rayons = []
# Noeuds
@onready var parent = get_parent()

func _ready():
	# Création du nouveau rayon
	for i in range (nombre_rayons):
		# Initialisation
		var nouveau_rayon = RayCast2D.new()
		# Paramétrage
		nouveau_rayon.name = "rayons" + str(i)
		nouveau_rayon.target_position = Vector2(1000, 0)
		print(nouveau_rayon.name, rad_to_deg(nouveau_rayon.rotation))
		# Ajout du noeud en tant qu'enfant
		add_child(nouveau_rayon)
		# Ajout du noeud dans la liste des rayons
		rayons.append(nouveau_rayon)

func _process(delta):
	for rayon in rayons:
		rayon.rotation = (parent.direction.angle() + (deg_to_rad(rayons.find(rayon) * (angle_vision / (nombre_rayons - 1)))))
