extends Node2D

# Variables globales
var rayons = []
var objets_visibles_rayon = []
var objets_visibles_joueur = []
var rencontre
# Propriétés du champ de vision
var nombre_rayons = 100
var angle_vision = 120.0
var distance_vision = 1000
# Noeuds
@onready var parent = get_parent()
@onready var noms_collision_layers = $Noms_collision_layers.noms_collision_layers
# Signaux
signal actualisation_noeuds_visibles(liste_noeuds)

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

func _process(_delta):

	# Pour chaque rayon
	for rayon in rayons:
		# Actualisation de la distance
		rayon.target_position = rayon.target_position.normalized() * distance_vision
		# Calcul des nouvelles collisions
		rayon.force_raycast_update()
		# Tant que le rayon est en collision
		while rayon.is_colliding():
			# Récupération de l'rencontreet
			rencontre = rayon.get_collider()
			# Si c'est un mur
			if rencontre.name == "Mur":
				# Actualisation de la distance
				rayon.target_position = rayon.target_position.normalized() * rayon.global_position.distance_to(rayon.get_collision_point())
				# Fin de la recherche
				break
			# Si ce n'est pas un mur
			# Ajout à la liste des rencontreets
			objets_visibles_rayon.append(rencontre)
			# Abstraction de l'rencontreet
			rayon.add_exception(rencontre)
			# Calcul des nouvelles collisions
			rayon.force_raycast_update()

		# Réinitialisation des exceptions
		for objet in objets_visibles_rayon:
			rayon.remove_exception(objet)

		# Utilisation des rencontreets visibles
		for objet in objets_visibles_rayon:
			if objet not in objets_visibles_joueur:
				objets_visibles_joueur.append(objet)
		
		# Réinitialisation des rencontreets visibles
		objets_visibles_rayon = []
	
	# Emmission de la liste des noeuds visibles après avoir parcouru tous les rayons
	emit_signal("actualisation_noeuds_visibles", objets_visibles_joueur)
	
	# Réinitialisation des objets visibles
	objets_visibles_joueur = []

# Fonction d'orientation
func orientation(direction):
	# Pour chaque rayon
	for rayon in rayons:
		rayon.rotation = direction.angle() + deg_to_rad((rayons.find(rayon) * angle_vision / (nombre_rayons - 1)) - (angle_vision / 2) - 90)
	
