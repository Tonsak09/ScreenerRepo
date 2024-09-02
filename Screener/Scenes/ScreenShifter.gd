extends Node3D

@export var bodyGrad : Gradient
@export var screenGrad : Gradient

@export var terminalMesh : MeshInstance3D
@export var bgMesh : MeshInstance3D

@export var jumpHeight : float
@export var animCurve : Curve
@export var animTimer : Timer

@export var squishAddFall : float 
@export var squishAddJump : float 
@export var squishSpeed : float 
@export var squishFalloff : float 

var rng : RandomNumberGenerator
var isJumping : bool 

var startScale : Vector3
var squishyTimer : float 
var squishMag : float 

func _ready():
	rng = RandomNumberGenerator.new()
	startScale = terminalMesh.scale
	
	SetColors()

func _process(delta):
	
	terminalMesh.scale = startScale + Vector3(0, sin(squishyTimer) * squishMag, 0)
	squishyTimer += squishSpeed * delta 
	squishMag = max(0, squishMag - squishFalloff * delta)
	
	if isJumping:
		var interp = (animTimer.wait_time - animTimer.time_left) / animTimer.wait_time
		terminalMesh.position = lerp(Vector3.ZERO, Vector3(0, jumpHeight, 0), animCurve.sample(interp) )
		

func _input(event):
	if event.is_action_pressed("ui_accept"):
		StartJump()

func StartJump():
	if isJumping:
		return
	
	isJumping = true
	AddSquish(squishAddJump)
	animTimer.start()

func EndJump():
	isJumping = false 
	terminalMesh.position = Vector3.ZERO
	AddSquish(squishAddFall)
	SetColors()

func AddSquish(squish : float):
	squishyTimer = 0.0
	squishMag += squish

func SetColors():
	var screenCol = screenGrad.sample(rng.randf())
	terminalMesh.material_override.set_shader_parameter("BodyColor", screenGrad.sample(rng.randf()))
	terminalMesh.material_override.set_shader_parameter("ScreenColor", screenCol)
	
	var bgrend : StandardMaterial3D
	bgrend = bgMesh.material_override
	bgrend.albedo_color = screenCol
