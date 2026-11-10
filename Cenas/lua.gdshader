shader_type canvas_item;

// =====================================================
// COSMOS RUSH - FUNDO ESPACIAL
// =====================================================

uniform vec4 background_top : source_color = vec4(0.004, 0.008, 0.035, 1.0);
uniform vec4 background_bottom : source_color = vec4(0.015, 0.025, 0.075, 1.0);

uniform vec4 star_color : source_color = vec4(0.85, 0.92, 1.0, 1.0);

uniform float star_brightness : hint_range(0.0, 4.0) = 1.4;
uniform float shooting_star_brightness : hint_range(0.0, 5.0) = 2.0;


// =====================================================
// NÚMERO ALEATÓRIO
// =====================================================

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);

	return fract(p.x * p.y);
}


// =====================================================
// CAMADA DE ESTRELAS
// =====================================================

float star_layer(
	vec2 uv,
	float grid_size,
	float size,
	float speed,
	float threshold
) {
	// Movimento muito lento do espaço
	uv.x += TIME * speed;

	vec2 grid_uv = uv * grid_size;

	vec2 cell = floor(grid_uv);
	vec2 local_uv = fract(grid_uv) - 0.5;

	// posição aleatória dentro da célula
	vec2 random_offset;

	random_offset.x =
		hash21(cell + vec2(12.7, 31.1)) - 0.5;

	random_offset.y =
		hash21(cell + vec2(73.2, 18.4)) - 0.5;

	random_offset *= 0.75;

	float random_value = hash21(cell);

	float distance_to_star =
		length(local_uv - random_offset);

	// tamanho variável
	float random_size =
		mix(
			size * 0.45,
			size,
			hash21(cell + 91.7)
		);

	float star =
		smoothstep(
			random_size,
			0.0,
			distance_to_star
		);

	// nem toda célula recebe uma estrela
	star *= step(threshold, random_value);

	// brilho piscando
	float twinkle =
		0.72 +
		0.28 *
		sin(
			TIME *
			mix(
				1.0,
				3.0,
				hash21(cell + 33.5)
			)
			+
			random_value * 6.28318
		);

	return star * twinkle;
}


// =====================================================
// ESTRELAS CADENTES
// =====================================================

float shooting_star(
	vec2 uv,
	float time_offset,
	float vertical_position,
	float speed
) {
	// ciclo da estrela cadente
	float cycle =
		mod(TIME * speed + time_offset, 8.0);

	// ela só aparece durante parte do ciclo
	float active =
		1.0 - step(1.4, cycle);

	float progress =
		clamp(cycle / 1.4, 0.0, 1.0);

	// começa fora da tela
	vec2 start =
		vec2(-0.25, vertical_position);

	// termina do outro lado e mais abaixo
	vec2 end =
		vec2(1.25, vertical_position + 0.35);

	vec2 head =
		mix(start, end, progress);

	// direção do rastro
	vec2 direction =
		normalize(end - start);

	vec2 difference =
		uv - head;

	float along =
		dot(difference, direction);

	float perpendicular =
		abs(
			difference.x * direction.y -
			difference.y * direction.x
		);

	// cabeça
	float head_glow =
		smoothstep(
			0.018,
			0.0,
			length(uv - head)
		);

	// rastro
	float trail_length = 0.22;

	float trail =
		smoothstep(
			0.012,
			0.0,
			perpendicular
		);

	trail *=
		smoothstep(
			-trail_length,
			0.0,
			along
		);

	trail *=
		1.0 -
		smoothstep(
			0.0,
			0.02,
			along
		);

	// desaparece suavemente
	float fade =
		sin(progress * 3.14159);

	return
		(head_glow * 1.8 + trail)
		*
		active
		*
		fade;
}


// =====================================================
// FRAGMENT
// =====================================================

void fragment() {

	vec2 uv = UV;


	// -------------------------------------------------
	// FUNDO
	// -------------------------------------------------

	vec3 color =
		mix(
			background_top.rgb,
			background_bottom.rgb,
			uv.y
		);


	// -------------------------------------------------
	// NEBULOSA SUAVE
	// -------------------------------------------------

	float nebula =
		sin(uv.x * 5.0 + uv.y * 3.0);

	nebula +=
		sin(
			uv.x * 11.0 -
			uv.y * 7.0 +
			1.5
		);

	nebula *= 0.5;

	nebula =
		smoothstep(
			0.35,
			1.0,
			nebula
		);

	color +=
		vec3(
			0.015,
			0.025,
			0.07
		)
		*
		nebula;


	// -------------------------------------------------
	// ESTRELAS DISTANTES
	// -------------------------------------------------

	float stars_far =
		star_layer(
			uv,
			45.0,
			0.055,
			0.002,
			0.82
		);


	// -------------------------------------------------
	// ESTRELAS MÉDIAS
	// -------------------------------------------------

	float stars_middle =
		star_layer(
			uv + vec2(0.13, 0.27),
			70.0,
			0.075,
			0.004,
			0.88
		);


	// -------------------------------------------------
	// ESTRELAS PRÓXIMAS
	// -------------------------------------------------

	float stars_near =
		star_layer(
			uv + vec2(0.41, 0.19),
			100.0,
			0.11,
			0.007,
			0.94
		);


	float stars =
		stars_far * 0.45
		+
		stars_middle * 0.75
		+
		stars_near * 1.15;


	color +=
		star_color.rgb
		*
		stars
		*
		star_brightness;


	// -------------------------------------------------
	// ESTRELAS CADENTES
	// -------------------------------------------------

	float shooting1 =
		shooting_star(
			uv,
			0.0,
			0.15,
			1.0
		);


	float shooting2 =
		shooting_star(
			uv,
			3.7,
			0.42,
			0.83
		);


	float shooting3 =
		shooting_star(
			uv,
			6.2,
			0.68,
			0.72
		);


	float shooting =
		shooting1
		+
		shooting2
		+
		shooting3;


	// cor levemente azulada
	vec3 shooting_color =
		vec3(
			0.75,
			0.88,
			1.0
		);


	color +=
		shooting_color
		*
		shooting
		*
		shooting_star_brightness;


	// -------------------------------------------------
	// VINHETA
	// -------------------------------------------------

	vec2 centered =
		uv - 0.5;

	float vignette =
		1.0 -
		dot(centered, centered) * 0.65;

	color *= vignette;


	// -------------------------------------------------
	// RESULTADO
	// -------------------------------------------------

	COLOR =
		vec4(
			color,
			1.0
		);
}