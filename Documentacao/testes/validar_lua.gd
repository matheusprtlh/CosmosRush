extends SceneTree

const L1 = "res://Cenas/lua.tscn"
const L2 = "res://Cenas/lua_2.tscn"
const L3 = "res://Cenas/lua_3.tscn"
const FINAL = "res://Cenas/final.tscn"
const BLUE = "res://Cenas/cristal_azul.tscn"
const GREEN = "res://Cenas/cristal_verde.tscn"
const LUNAR_TEXTURE = "res://TileMaps/sTileset.png"
const EXPECTED_TILES = {L1: 142, L2: 160, L3: 109}

var player
var enemy
var early := 0.0
var damage_frames := 0
var taken: Array[String] = []
var enemy_min := INF
var enemy_max := -INF
var enemy_turns := 0
var enemy_direction := 0
var failed := false
var screenshots := false
var shot_dir := ""
var jumps := 0

func _initialize():
	call_deferred("run")

func tick(n: int = 1):
	for i in n:
		await physics_frame
		if is_instance_valid(player) and player.protecao_dano_restante > 0:
			damage_frames += 1
			if damage_frames == 1:
				print("DANO em ", player.position, " inimigo ", enemy.position if is_instance_valid(enemy) else Vector2.ZERO)
		if is_instance_valid(enemy):
			enemy_min = minf(enemy_min, enemy.position.x)
			enemy_max = maxf(enemy_max, enemy.position.x)
			if enemy_direction != enemy.direcao:
				if enemy_direction != 0:
					enemy_turns += 1
				enemy_direction = enemy.direcao

func check(value: bool, message: String):
	if not value:
		failed = true
		printerr("FAIL ", message)
	return value

func grounded(y: float):
	return is_instance_valid(player) and player.is_on_floor() and absf(player.position.y + 11.62 - y) < 2

func horizontal(side: float):
	Input.action_release("ui_left")
	Input.action_release("ui_right")
	if side < 0:
		Input.action_press("ui_left")
	if side > 0:
		Input.action_press("ui_right")

func move(x: float):
	if not is_instance_valid(player) or player.saindo_da_fase or failed:
		return
	var dist: float = x - player.position.x
	horizontal(dist)
	for i in 195:
		if not is_instance_valid(player) or player.saindo_da_fase:
			break
		if absf(player.position.x - x) < 3.5 or signf(x - player.position.x) != signf(dist):
			break
		await tick()
	horizontal(0)

func jump(start: float, x: float, y: float):
	if failed:
		return
	await move(start)
	if not check(player.is_on_floor(), "decolagem em %s, alvo %s,%s" % [player.position, x, y]):
		return
	var feet: float = player.position.y + 11.62
	if is_instance_valid(enemy):
		print("ENEMY at jump ", player.position, " vs ", enemy.position, " dir=",enemy.direcao)
	Input.action_press("ui_accept")
	await move(x)
	Input.action_release("ui_accept")
	for i in 105:
		if player.is_on_floor() or player.saindo_da_fase:
			break
		await tick()
	if check(grounded(y) and absf(player.position.x - x) <= 9, "pouso %s,%s: %s piso=%s" % [x,y,player.position,player.is_on_floor()]):
		jumps += 1
		print("PULO ", snappedf(feet,0.1), " -> ", y, " x=", snappedf(player.position.x,0.1), " de=",start)

func drop(x: float, y: float):
	if failed:
		return
	await move(x)
	await tick(68)
	if check(grounded(y), "descida para %s: %s" % [y,player.position]):
		print("DESCIDA piso=", y, " x=", player.position.x)

func transition(target: String, seconds: float = 5.0):
	if failed:
		return
	for i in int(seconds * 60):
		if is_instance_valid(current_scene) and current_scene.scene_file_path == target:
			print("TRANSIÇÃO ", target)
			return
		await tick()
	check(false, "transição esperada " + target)

func start(path: String):
	horizontal(0)
	player = null
	enemy = null
	change_scene_to_file(path)
	await transition(path, 2)

func check_lunar_tiles():
	var map := current_scene.get_node("TileMapLayer") as TileMapLayer
	var atlas := map.tile_set.get_source(0) as TileSetAtlasSource
	var camera := current_scene.get_node("Camera2D") as Camera2D
	var cells := map.get_used_cells()
	var expected: int = EXPECTED_TILES[current_scene.scene_file_path]
	check(atlas.texture.resource_path == LUNAR_TEXTURE, "textura do atlas lunar")
	check(map.tile_set.tile_size == Vector2i(16, 16), "tamanho da célula")
	check(cells.size() == expected and map.collision_enabled, "contagem e colisão do terreno")
	check(camera.enabled and camera.zoom == Vector2(2, 2), "câmera lunar 2×")
	for cell in cells:
		var coords := map.get_cell_atlas_coords(cell)
		var data := map.get_cell_tile_data(cell)
		var lunar_tile := map.get_cell_source_id(cell) == 0 and Rect2i(5, 0, 3, 3).has_point(coords)
		if not check(lunar_tile and data != null and data.get_collision_polygons_count(0) > 0,
				"tile lunar sólido em %s" % cell):
			return
	print("TERRENO ", current_scene.scene_file_path, " células=", cells.size(), " atlas=", atlas.texture.resource_path)

func capture(capture_name: String):
	if not screenshots or capture_name.is_empty():
		return
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	var path := shot_dir.path_join(capture_name + ".png")
	if check(picture.save_png(path) == OK, "salvar print " + capture_name):
		print("CAPTURA ", path)

func setup(y: float, total: int, capture_name: String = ""):
	check_lunar_tiles()
	player = current_scene.get_node("PlayerLua")
	enemy = current_scene.get_node_or_null("EnemyLua")
	enemy_min = INF
	enemy_max = -INF
	enemy_turns = 0
	enemy_direction = 0
	taken.clear()
	damage_frames = 0
	jumps = 0
	var capsules := 0
	for node in current_scene.get_children():
		if node.scene_file_path == "res://Cenas/capsula.tscn":
			capsules += 1
			node.capsula_coletada.connect(func(): taken.append(node.name))
	check(capsules == total, "cápsulas esperadas %d, encontradas %d" % [total,capsules])
	await tick(100)
	if check(grounded(y) and player.oxigenio_atual >= 91 and not player.saindo_da_fase and damage_frames == 0, "spawn seguro " + current_scene.scene_file_path + " " + str(player.position)):
		print("SPAWN ", player.position, " piso=", y, " O2=", player.oxigenio_atual)
	await capture(capture_name)

func phase_end(total: int, expected_jumps: int, patrol: bool):
	check(taken.size() == total, "coletas de cápsulas %s, esperadas %d" % [taken,total])
	check(jumps == expected_jumps, "saltos %d, esperados %d" % [jumps, expected_jumps])
	check(not player.ja_morreu and player.oxigenio_atual > 0, "oxigênio positivo")
	check(damage_frames == 0, "evitar inimigo: %d quadros sob proteção" % damage_frames)
	if patrol:
		check(enemy_min + 45 < enemy_max and enemy_turns >= 1 and enemy.is_on_floor(), "patrulha [%s, %s], inversões %d" % [enemy_min,enemy_max,enemy_turns])
	print("SAÍDA ", current_scene.scene_file_path, " saltos=", jumps, " O2=", player.oxigenio_atual,
			" cápsulas=", taken, " dano=", damage_frames)
	if patrol:
		print("PATRULHA x=", enemy_min, "..", enemy_max, " inversões=", enemy_turns)

func moon_one(blue: bool):
	await setup(208, 2, "Cosmos-Rush-Lua-1")
	await jump(461 + early, 540, 208)
	await move(555)
	await jump(570 + early, 651, 192)
	await jump(666 + early, 757, 192)
	await jump(755 + early, 824, 176)
	if failed:
		return
	if blue:
		await move(873)
		await jump(877 + early, 922, 128)
	else:
		await jump(826 + early, 922, 128)
	await jump(913 - early, 843, 80)
	await move(821)
	await jump(842 + early, 915, 32)
	await jump(906 - early, 811, 0)
	await jump(760 - early, 683, 0)
	await jump(630 - early, 553, 0)
	await jump(502 - early, 435, 0)
	phase_end(2, 11, true)
	await move(404)
	await transition(L2)

func moon_two():
	if failed:
		return
	await setup(32, 3, "Cosmos-Rush-Lua-2")
	await move(780)
	await drop(454,112)
	await move(658)
	await drop(862,208)
	await jump(840 - early, 730, 208)
	await jump(721 - early, 588, 208)
	await move(484)
	if check(root.get_node("Gamedata").cristal_coletado(GREEN), "cristal verde"):
		print("CRISTAL verde coletado na Lua 2")
	await jump(500 - early, 433, 208)
	phase_end(3, 3, true)
	await move(406)
	await transition(L3)

func moon_three(expect_blue_here: bool, launch: bool):
	if failed:
		return
	await setup(208, 2, "Cosmos-Rush-Lua-3")
	var data = root.get_node("Gamedata")
	var count: int = data.cristais
	check(current_scene.has_node("cristalAzul") == expect_blue_here, "presença do cristal azul na Lua 3")
	await jump(493 + early, 578, 176)
	await move(615)
	await jump(649 + early, 736, 144)
	await jump(806 + early, 878, 112)
	await jump(863 - early, 788, 64)
	await move(750)
	await jump(724 - early, 642, 32)
	if expect_blue_here:
		await move(590)
		if check(data.cristais == count + 1 and data.cristal_coletado(BLUE), "coleta do azul na Lua 3"):
			print("CRISTAL azul coletado na Lua 3, total=", data.cristais)
	else:
		await move(600)
		if check(data.cristais == count, "azul não contou duas vezes"):
			print("CRISTAL azul ausente na Lua 3, total mantido=", count)
	await jump(575 - early, 496, 0)
	phase_end(2, 6, false)
	if failed:
		return
	await move(449)
	var ship = current_scene.get_node("NaveFinal")
	await tick(10)
	check(data.cristais == (4 if launch else 3), "total de cristais ao atingir a nave")
	check(ship.overlaps_body(player) or launch, "atingir a área da nave")
	check(ship.ativada == launch, "nave com %d cristais, ativação esperada %s" % [data.cristais,launch])
	if launch:
		for i in 720:
			if ship.subindo and ship.position.y < ship.posicao_original.y - 10.0:
				break
			await tick()
		if check(ship.subindo and ship.position.y < ship.posicao_original.y - 10.0, "subida visível da nave"):
			print("NAVE decolou com ", data.cristais, " cristais; y=", ship.position.y)
		await transition(FINAL, 18)
		await tick(100)
		check(current_scene.scene_file_path == FINAL, "cena final após a decolagem")
	else:
		await tick(200)
		if check(current_scene.scene_file_path == L3 and not ship.ativada, "nave permaneceu no patamar com três cristais"):
			print("NAVE bloqueada com ", data.cristais, " cristais")

func seed_progress(mars: bool):
	var data = root.get_node("Gamedata")
	data.resetar_jogo()
	data.coletar_cristal("res://Cenas/cristalAmarelo.tscn")
	if mars:
		data.coletar_cristal("res://Cenas/cristal_roxo.tscn")

func run():
	var args := OS.get_cmdline_user_args()
	var mode := args[0] if not args.is_empty() else "base"
	if mode not in ["base", "early", "late"] or (args.has("--shots") and args.find("--shots") + 1 >= args.size()):
		printerr("Uso: base|early|late [--shots DIRETÓRIO]")
		quit(2)
		return
	if args.has("--shots"):
		if DisplayServer.get_name() == "headless":
			printerr("--shots exige um driver de vídeo gráfico")
			quit(2)
			return
		screenshots = true
		shot_dir = args[args.find("--shots") + 1]
	seed(4318)
	early = 0.0 if mode == "base" else (-5.0 if mode == "early" else 5.0)
	seed_progress(mode != "early")
	await start(L1)
	await moon_one(mode != "late")
	if not failed:
		var collected: bool = root.get_node("Gamedata").cristal_coletado(BLUE)
		if check(collected == (mode != "late"), "azul na Lua 1"):
			print("CRISTAL azul coletado na Lua 1: ", collected)
	await moon_two()
	await moon_three(mode == "late", mode != "early")
	print("RESULTADO ", mode, ": ", "FALHOU" if failed else "PASSOU")
	quit(1 if failed else 0)
