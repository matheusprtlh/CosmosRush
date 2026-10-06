shader_type canvas_item;

// 0.0 = fora da tela pela esquerda
// 1.0 = tela completamente preenchida
// 2.0 = saiu completamente pela direita
uniform float progress : hint_range(0.0, 2.0) = 0.0;

// Pixels bem pequenos
uniform float pixel_size : hint_range(1.0, 20.0) = 4.0;

uniform vec4 fade_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);


float random(vec2 p) {
	return fract(
		sin(dot(p, vec2(127.1, 311.7))) * 43758.5453
	);
}


void fragment() {
	// Cria pequenos quadrados
	vec2 grid = floor(FRAGCOORD.xy / pixel_size);

	// Número aleatório para cada quadradinho
	float noise = random(grid);

	// Pequena irregularidade na borda
	float variation = (noise - 0.5) * 0.10;

	float mask = 0.0;


	// =========================================
	// ENTRADA
	// Esquerda → Direita
	// =========================================
	if (progress <= 1.0) {
		float front = progress * 1.1;

		mask = step(
			UV.x + variation,
			front
		);
	}


	// =========================================
	// SAÍDA
	// Continua indo para a direita
	// =========================================
	else {
		float exit_progress = progress - 1.0;

		float back = exit_progress * 1.1;

		mask = step(
			back,
			UV.x + variation
		);
	}


	COLOR = vec4(
		fade_color.rgb,
		fade_color.a * mask
	);
}