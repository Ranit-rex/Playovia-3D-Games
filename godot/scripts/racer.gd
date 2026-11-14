extends Node3D
const LANES = [-3.2, 0.0, 3.2]
var speed := 0.0
var distance := 0.0
var score := 0
var lives := 3
var player: Node3D
var camera: Camera3D
var hud: CanvasLayer
var info: Label
var traffic: Array[Node3D] = []
var rng := RandomNumberGenerator.new()
var touch_left := false
var touch_right := false
var touch_go := false

func mat(c: Color, metal := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.metallic = metal
	m.roughness = 0.28
	return m

func block(parent: Node3D, size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	n.mesh = mesh
	n.position = pos
	n.material_override = material
	parent.add_child(n)
	return n

func _ready() -> void:
	rng.randomize()
	build_world()
	build_car()
	build_hud()
	for i in range(10):
		spawn_car(-20.0 - i * 19.0)

func build_world() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.58,0.68,0.85)
	env.ambient_light_energy = 0.9
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48,-25,0)
	sun.shadow_enabled = true
	sun.light_energy = 1.35
	add_child(sun)
	block(self,Vector3(13,0.2,220),Vector3(0,-0.15,-95),mat(Color(0.075,0.09,0.13)))
	block(self,Vector3(36,0.12,220),Vector3(0,-0.28,-95),mat(Color(0.035,0.13,0.10)))
	for x in [-6.5,6.5]:
		block(self,Vector3(0.2,0.08,220),Vector3(x,-0.03,-95),mat(Color(0.95,0.76,0.36)))
	for z in range(-205,15,12):
		for x in [-1.6,1.6]:
			block(self,Vector3(0.12,0.04,5.5),Vector3(x,-0.03,z),mat(Color(0.9,0.94,1)))
	for i in range(26):
		var side := -1.0 if i % 2 == 0 else 1.0
		var h := rng.randf_range(6,20)
		var w := rng.randf_range(4,7)
		var z := -float(i)*8.5-8
		var building := block(self,Vector3(w,h,7),Vector3(side*rng.randf_range(11,18),h/2-0.2,z),mat(Color.from_hsv(rng.randf(),0.38,rng.randf_range(0.22,0.42))))
		for floor_id in range(int(h/2.3)):
			for wx in [-1,1]:
				block(building,Vector3(0.08,0.62,0.85),Vector3(wx*(w/2+0.05),-h/2+1.5+floor_id*2.3,-0.1),mat(Color(0.22,0.7,1)))

func build_car() -> void:
	player = Node3D.new()
	add_child(player)
	block(player,Vector3(1.85,0.65,3.5),Vector3(0,0.68,0),mat(Color(0.32,0.06,0.92),0.7))
	block(player,Vector3(1.38,0.62,1.6),Vector3(0,1.25,-0.2),mat(Color(0.05,0.72,0.95),0.35))
	for x in [-0.98,0.98]:
		for z in [-1.1,1.1]:
			var wheel := MeshInstance3D.new()
			var mesh := CylinderMesh.new()
			mesh.top_radius=0.38
			mesh.bottom_radius=0.38
			mesh.height=0.24
			wheel.mesh=mesh
			wheel.rotation_degrees.z=90
			wheel.position=Vector3(x,0.38,z)
			wheel.material_override=mat(Color(0.02,0.025,0.04))
			player.add_child(wheel)
	camera=Camera3D.new()
	camera.position=Vector3(0,5.5,10.5)
	camera.rotation_degrees=Vector3(-18,0,0)
	camera.current=true
	player.add_child(camera)

func spawn_car(z: float) -> void:
	var car := Node3D.new()
	car.position=Vector3(LANES[rng.randi_range(0,2)],0,z)
	add_child(car)
	var colors=[Color(0.95,0.22,0.16),Color(0.12,0.76,0.48),Color(0.98,0.65,0.1),Color(0.1,0.48,0.96)]
	block(car,Vector3(1.75,0.72,3.2),Vector3(0,0.62,0),mat(colors[rng.randi_range(0,3)],0.25))
	block(car,Vector3(1.3,0.58,1.5),Vector3(0,1.2,-0.2),mat(Color(0.06,0.12,0.2),0.3))
	traffic.append(car)

func build_hud() -> void:
	hud=CanvasLayer.new()
	add_child(hud)
	var panel=PanelContainer.new()
	panel.position=Vector2(18,18)
	var style=StyleBoxFlat.new()
	style.bg_color=Color(0.02,0.035,0.08,0.86)
	style.set_corner_radius_all(14)
	style.content_margin_left=16
	style.content_margin_right=16
	style.content_margin_top=10
	style.content_margin_bottom=10
	panel.add_theme_stylebox_override("panel",style)
	hud.add_child(panel)
	info=Label.new()
	info.add_theme_color_override("font_color",Color.WHITE)
	info.add_theme_font_size_override("font_size",20)
	panel.add_child(info)
	var hint=Label.new()
	hint.text="WASD / ARROWS  •  DODGE TRAFFIC"
	hint.position=Vector2(20,82)
	hint.add_theme_color_override("font_color",Color(0.85,0.92,1))
	hud.add_child(hint)
	add_touch("◀",Vector2(22,-104),"left")
	add_touch("▶",Vector2(108,-104),"right")
	add_touch("▲",Vector2(-102,-104),"go")

func add_touch(caption: String, offset: Vector2, action: String) -> void:
	var b=Button.new()
	b.text=caption
	b.custom_minimum_size=Vector2(76,76)
	b.anchor_left=1.0 if action=="go" else 0.0
	b.anchor_right=b.anchor_left
	b.anchor_top=1.0
	b.anchor_bottom=1.0
	b.offset_left=offset.x
	b.offset_right=offset.x+76
	b.offset_top=offset.y
	b.offset_bottom=offset.y+76
	b.add_theme_font_size_override("font_size",28)
	hud.add_child(b)
	b.button_down.connect(func(): set_touch(action,true))
	b.button_up.connect(func(): set_touch(action,false))

func set_touch(action: String, value: bool) -> void:
	if action=="left": touch_left=value
	if action=="right": touch_right=value
	if action=="go": touch_go=value

func _physics_process(delta: float) -> void:
	var steer=Input.get_axis("ui_left","ui_right")
	if touch_left: steer=-1.0
	if touch_right: steer=1.0
	var accelerating=Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP) or touch_go
	speed=move_toward(speed,48.0 if accelerating else 27.0,delta*18.0)
	distance+=speed*delta
	player.position.x=clampf(player.position.x+steer*delta*(4.5+speed*0.035),-4.8,4.8)
	player.rotation.z=lerpf(player.rotation.z,-steer*0.09,delta*5)
	for car in traffic:
		car.position.z+=speed*delta*0.92
		if car.position.z>12:
			car.position.z=-rng.randf_range(145,205)
			car.position.x=LANES[rng.randi_range(0,2)]
			score+=1
		if car.position.z>-2.2 and car.position.z<2.2 and absf(car.position.x-player.position.x)<1.45:
			lives-=1
			car.position.z=-190
			if lives<=0:
				game_over()
	info.text="DISTANCE  %05d    CARS  %02d    SPEED  %03d    LIVES  %d" % [int(distance),score,int(speed*3.2),lives]
	camera.position.x=lerpf(camera.position.x,player.position.x*0.35,delta*2.5)

func game_over() -> void:
	set_physics_process(false)
	var panel=ColorRect.new()
	panel.color=Color(0.01,0.02,0.06,0.86)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.add_child(panel)
	var label=Label.new()
	label.text="RACE OVER\nDISTANCE %d\nTAP TO RESTART" % int(distance)
	label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size",42)
	panel.add_child(label)
	panel.gui_input.connect(func(event):
		if event is InputEventMouseButton or event is InputEventScreenTouch:
			get_tree().reload_current_scene()
	)
