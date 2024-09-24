extends Node

@onready var joueur = $Joueur
@onready var mob = $Mob
@onready var position_depart_joueur = $Position_depart_joueur
@onready var position_depart_mob = $Position_depart_mob

func _ready():
	new_game()

func new_game():
	joueur.start(position_depart_joueur.position)
	mob.position = position_depart_mob.position
