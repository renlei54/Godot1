extends Node

# Signaux
signal degats_pris(vie_actuelle)
signal suppression_noeud(noeud)

# Fonction de prise de degats
func prise_de_degats(entite, vie, degats):
	vie -= degats
	emit_signal("degats_pris", vie)
	# Mort du noeud parent
	if vie <= 0:
		emit_signal("suppression_noeud", entite)
		entite.queue_free()
		
