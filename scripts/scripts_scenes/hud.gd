extends CanvasGroup

# variables globales
@onready var joueur = $/root/Main/Joueur
@onready var barre_vie_joueur = $Vie_joueur

func _ready():
	# initialisation de la barre de vie
	barre_vie_joueur.max_value = joueur.vie_max
	barre_vie_joueur.value = joueur.vie
	joueur.connect("modification_vie", Callable(self, "_lorsque_modification_vie_joueur"))
	
# actualisation lorsque la vie du joueur est modifiée
func _lorsque_modification_vie_joueur(nouvelle_valeur_vie_joueur):
	barre_vie_joueur.value = nouvelle_valeur_vie_joueur
