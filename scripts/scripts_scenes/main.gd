extends Node

func _ready():
	new_game()

func new_game():
	$Joueur.start($Start_position_joueur.position)
