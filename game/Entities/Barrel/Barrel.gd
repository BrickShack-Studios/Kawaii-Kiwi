extends RigidBody

const ZERO := Vector3()

func _integrate_forces(state : PhysicsDirectBodyState) -> void:
	if (state.angular_velocity.length() < 5):
		state.angular_velocity = lerp(state.angular_velocity, ZERO, 0.1)
	if (state.angular_velocity.length() < 0.1):
		state.angular_velocity = ZERO
	return

