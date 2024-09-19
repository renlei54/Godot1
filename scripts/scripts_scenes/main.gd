extends Node

@onready var joueur = $Joueur
@onready var position_depart_joueur = $Position_depart_joueur

func _ready():
	new_game()

func new_game():
	joueur.start(position_depart_joueur.position)
