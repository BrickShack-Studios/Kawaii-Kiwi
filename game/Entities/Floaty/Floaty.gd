extends KinematicBody

export (float) var bobbiness : float
export (float) var drift     : float

var t  := rand_range(0, 2*PI)
var dt := 0.02

func _physics_process(delta : float) -> void:
	translation.y += sin(t) * bobbiness
	rotation.y += drift - (0 if rotation.y < 2 * PI else 2 * PI)
	
	t += dt
	if (t > 2*PI): t -= 2*PI
	
	return

