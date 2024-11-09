extends CollisionPolygon2D

@export var arc_angle : float = 180 # Angle de l'arc en degrés
@export var arc_radius : float = 30 # Rayon de l'arc
@export var segments : int = 8 # Nombre de segments pour définir la courbe de l'arc
@export var start_angle : float = -90 # Angle de départ en degrés

@onready var visual_polygon = $Polygon2D # Référence au Polygon2D

func _ready():
	update_collision_polygon()
	visual_polygon.visible = false

func update_collision_polygon():
	var points = []
	
	# Ajouter le point central
	points.append(Vector2.ZERO)
	
	# Convertir les angles en radians
	var start_rad = deg_to_rad(start_angle)
	var end_rad = deg_to_rad(start_angle + arc_angle)
	
	# Calculer les points de l'arc
	for i in range(segments + 1):
		var t = i / float(segments)
		var angle = lerp(start_rad, end_rad, t)
		var x = cos(angle) * arc_radius
		var y = sin(angle) * arc_radius
		points.append(Vector2(x, y))
	
	# Définir la forme du CollisionPolygon2D
	self.polygon = points
	
	# Mettre à jour la forme du Polygon2D pour correspondre à celle de la hitbox
	visual_polygon.polygon = points
	visual_polygon.color = Color(0, 0, 1, 0.3) # Bleu avec transparence
