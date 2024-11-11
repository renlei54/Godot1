extends Node

# Variables globales

# Noeuds
@onready var joueur = $Joueur
@onready var mob = $Mob
# @onready var mob2 = $Mob2
@onready var position_depart_joueur = $Position_depart_joueur
@onready var position_depart_mob = $Position_depart_mob
@onready var position_depart_mob2 = $Position_depart_mob2
@onready var menu = $CanvasLayer/Menu
@onready var liste_entites = []
@onready var navigation_region = $NavigationRegion2D

# Signaux
signal suppression_entite(entite)

func _ready():
	recherche_entites()
	joueur.recherche_mobs()
	connection_elimination_entite()
	new_game()

func new_game():
	joueur.start(position_depart_joueur.position)
	mob.position = position_depart_mob.position
	# mob2.position = position_depart_mob2.position

func connection_elimination_entite():
	for entite in liste_entites:
		for sous_enfant in entite.get_children(): 
			if sous_enfant.name == "Composant_degats":
				sous_enfant.connect("suppression_noeud", Callable(self, "_lorsque_suppression_noeud"))

func _lorsque_suppression_noeud(noeud):
	liste_entites.erase(noeud)
	emit_signal("suppression_entite", noeud)
	if noeud.name == "Joueur":
		menu.visible = true

func recherche_entites():
	liste_entites = []
	for entite in get_children():
		liste_entites.append(entite)

