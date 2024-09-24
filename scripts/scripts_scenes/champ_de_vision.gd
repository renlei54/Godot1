extends Node2D

# Variables globales
var nombre_rayons = 50
var angle_vision = 120.0
var rayons = []
# Noeuds
@onready var parent = get_parent()
@onready var noms_collision_layers = $Noms_collision_layers.noms_collision_layers
@onready var mob = $/root/Main/Mob

func _ready():
	# Création du nouveau rayon
	for i in range (nombre_rayons):
		# Initialisation
		var nouveau_rayon = RayCast2D.new()
		# Paramétrage
		nouveau_rayon.name = "rayons" + str(i)
		nouveau_rayon.set_collision_mask_value(4, true)
		nouveau_rayon.set_collision_mask_value(3, true)
		# Ajout du noeud en tant qu'enfant
		add_child(nouveau_rayon)
		# Ajout du noeud dans la liste des rayons
		rayons.append(nouveau_rayon)
func _process(delta):

	var objects_collide = []
	var mob_visible = false

	for rayon in rayons:
		var target_position = rayon.target_position.normalized() * 1000
		rayon.target_position = target_position
		rayon.force_raycast_update()
		while rayon.is_colliding():
			var obj = rayon.get_collider()
			if obj.name == "Mur":
				target_position = rayon.target_position.normalized() * rayon.global_position.distance_to(rayon.get_collision_point())
				break
			objects_collide.append(obj)
			rayon.add_exception(obj)
			rayon.force_raycast_update()

		# Réinitialiser les exceptions après avoir détecté toutes les collisions
		for obj in objects_collide:
			rayon.remove_exception(obj)

		# Utiliser les objets détectés
		for obj in objects_collide:
			if obj.name == "Mob":
				mob_visible = true
				
		objects_collide = []
		rayon.target_position = target_position
	# Mettre à jour la visibilité du mob après avoir vérifié tous les rayons
	mob.visible = mob_visible

func orientation(direction):
	for rayon in rayons:
		rayon.rotation = direction.angle() + deg_to_rad((rayons.find(rayon) * angle_vision / (nombre_rayons - 1)) - (angle_vision / 2) - 90)
	

