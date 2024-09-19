extends CanvasGroup

# variables globales
@onready var joueur = get_parent()
@onready var barre_vie_joueur = $Vie_joueur
@onready var barre_endurance_joueur = $Endurance_joueur
@onready var compteur_potions_vie = $Compteur_potions_vie

func _ready():
	# initialisation de la barre de vie
	barre_vie_joueur.max_value = joueur.vie_max
	barre_vie_joueur.value = joueur.vie
	joueur.connect("modification_vie", Callable(self, "_lorsque_modification_vie_joueur"))
	
	# initialisation de la barre d'endurance
	barre_endurance_joueur.max_value = joueur.endurance_max
	barre_endurance_joueur.value = joueur.endurance
	joueur.connect("modification_endurance", Callable(self, "_lorsque_modification_endurance_joueur"))
	
	# initialisation du compteur de potions
	compteur_potions_vie.text = str(joueur.nombre_potions_vie)
	joueur.connect("modification_nombre_potions_vie", Callable(self, "_lorsque_modification_nombre_potions_vie"))
	
# actualisation lorsque la vie du joueur est modifiée
func _lorsque_modification_vie_joueur(nouvelle_valeur_vie_joueur):
	barre_vie_joueur.value = nouvelle_valeur_vie_joueur

# actualisation losque l'endurance du joueur est modifiée
func _lorsque_modification_endurance_joueur(nouvelle_valeur_endurance_joueur):
	barre_endurance_joueur.value = nouvelle_valeur_endurance_joueur

# actualisation lorsque le nombre de potions de vie du joueur est modifié
func _lorsque_modification_nombre_potions_vie(nouveau_nombre_potions_vie):
	compteur_potions_vie.text = str(nouveau_nombre_potions_vie)
