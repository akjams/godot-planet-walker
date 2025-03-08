class_name Hero extends CharacterBody3D

@onready var worldCollider: CollisionShape3D = $CollisionShape3D

@export var skin: GobotSkin
@export var camYaw: Node3D
@export var camPitch: Node3D
@export var cam: Camera3D
@export var gravDecider: GravityDecider
@export var footcast: RayCast3D

@export var lookSensitivity: float = .0009
@export var jumpVel := 7.
@export var autoBhop := true
@export var walkSpeed := 7.
@export var sprintSpeed := 8.5
@export var groundAccel := 11.
@export var groundDecel := 7.
@export var groundFriction := 3.5
@export var airCap := .85
@export var airAccel := 800.
@export var airSpeed := 500.

var wishDir := Vector3.ZERO
var horizontalPlane: Plane
var targetBasis: Basis

var lastJumpTimeMs: int = -9000

func getGravity() -> Vector3:
	return gravDecider.getGravity()

func getGravDir() -> Vector3:
	var grav := getGravity()
	if grav.is_equal_approx(Vector3.ZERO):
		return Vector3.UP
	return grav.normalized()

func isNearlyOnFloor() -> bool:
	return is_on_floor() || \
		(footcast.is_colliding() && !isJumping())

func isJumping() -> bool:
	return skin.isJumping() || \
		lastJumpTimeMs + 100 > Util.nowMs()

func getSpeed() -> float:
	return walkSpeed

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseMotion:
		camYaw.rotate_y(-event.relative.x * lookSensitivity)
		camPitch.rotate_x(-event.relative.y * lookSensitivity)
		camPitch.rotation.x = clampf(camPitch.rotation.x, -PI/2 + .2, PI/2 - .2)

func airPhysics(delta: float):
	velocity += getGravity() * delta
	var speedInWishDir := wishDir.dot(velocity)
	var cappedSpeed = min((airSpeed * wishDir).length(), airCap)
	var addSpeedTillCap = cappedSpeed - speedInWishDir
	if addSpeedTillCap > 0:
		var accelSpeed = airAccel * airSpeed * delta
		accelSpeed = min(accelSpeed, addSpeedTillCap)
		velocity += accelSpeed * wishDir

func groundPhysics(delta: float):
	var speedInWishDir := wishDir.dot(velocity)
	var addSpeedTillCap := getSpeed() - speedInWishDir
	if addSpeedTillCap > 0:
		var accelSpeed := groundAccel * delta * getSpeed()
		accelSpeed = min(accelSpeed, addSpeedTillCap)
		velocity += accelSpeed * wishDir

	# friction
	var control := maxf(velocity.length(), groundDecel)
	var drop := control * groundFriction * delta
	var newSpeed := maxf(velocity.length() - drop, 0.)
	if velocity.length() > 0:
		newSpeed /= velocity.length()
	if wishDir.length() > .1:
		var x = 0
		velocity.x += x
	velocity *= newSpeed

	if Input.is_action_just_pressed("hero-jump") \
		or (autoBhop and Input.is_action_pressed('hero-jump')):
		var jumpVec := -getGravDir() * jumpVel
		velocity += jumpVec
		skin.jump()
		# skin.flip()
		lastJumpTimeMs = Util.nowMs()

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector('hero-left', 'hero-right', 'hero-forward', 'hero-back')
	wishDir = (cam.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	horizontalPlane = Plane(-getGravDir())
	wishDir = horizontalPlane.project(wishDir).normalized()

	feetToFloor(delta)
	faceForward(delta)

	if isNearlyOnFloor():
		groundPhysics(delta)
	else:
		airPhysics(delta)

	# for move_and_slide is_on_floor
	up_direction = -getGravDir()
	move_and_slide()
	setSkinAnimation()

	# on small spherical planets, snap our feet down
	# avoid floating into slight orbits
	# avoid animation stutter
	if isNearlyOnFloor():
		apply_floor_snap()

func feetToFloor(delta: float):
	var oldZ := basis.z
	var newY := -getGravDir()

	var amountOfOldZPointingAtNewY := oldZ.dot(newY)
	var newZ := (oldZ - newY * amountOfOldZPointingAtNewY).normalized()
	var newX := newY.cross(newZ).normalized()

	targetBasis = Basis(newX, newY, newZ)
	var targetQuat = Quaternion(targetBasis)
	var currQuat = Quaternion(basis)
	var slerpedQuat = currQuat.slerp(targetQuat, delta * 3)
	basis = Basis(slerpedQuat)
	# basis = basis.slerp(targetBasis, delta * 3)

func faceForward(delta: float):
	var desiredForward := wishDir

	var currForward := -targetBasis.z
	var bigAngle := currForward.signed_angle_to(desiredForward, targetBasis.y)
	var amount := delta * 18
	amount = clampf(amount, 0, 1)
	var smallAngle := bigAngle * amount
	rotate(targetBasis.y, smallAngle)
	camYaw.rotate_y(-smallAngle)

func setSkinAnimation():
	if isNearlyOnFloor():
		if wishDir.is_equal_approx(Vector3.ZERO):
			skin.idle()
		else:
			skin.run()
	else:
		var isVelWithGravity := velocity.dot(getGravDir()) > 0
		if isVelWithGravity:
			skin.fall()
		else:
			# skin.jump is done on the action.
			# if we fall away from gravity, idle instead
			pass




func _to_string() -> String:
	return 'Hero: pos-vel %s-%s' % [position, velocity]
