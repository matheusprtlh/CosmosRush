
shader_type canvas_item;

render_mode unshaded, blend_mix;

uniform vec4 cor_particula : source_color = vec4(1.0, 0.94, 0.55, 1.0);

// Quantidade e aparencia
uniform float quantidade : hint_range(5.0, 100.0) = 55.0;
uniform float tamanho_pixels : hint_range(1.0, 4.0) = 1.0;
uniform float transparencia : hint_range(0.0, 1.0) = 0.75;

// Movimento
uniform float velocidade : hint_range(0.0, 2.0) = 0.15;

// Resolucao de referencia do jogo
uniform vec2 resolucao = vec2(803.0, 453.0);

float random(vec2 p) {
    return fract(
        sin(dot(p, vec2(127.1, 311.7))) * 43758.5453
    );
}

void fragment() {
    // Coordenadas em pixels
    vec2 pixel = floor(UV * resolucao);

    // Movimento horizontal lento
    vec2 pos = pixel / resolucao * quantidade;
    pos.x -= TIME * velocidade;

    // Oscilacao suave no vento
    pos.y += sin(TIME * 0.5 + pos.x * 0.6) * 0.10;

    vec2 id = floor(pos);
    vec2 local = fract(pos);

    // Posicao aleatoria na celula
    vec2 centro = vec2(
        random(id + 2.0),
        random(id + 7.0)
    );

    // Tamanho real em pixels
    vec2 tamanho = tamanho_pixels * quantidade / resolucao;

    vec2 distancia = abs(local - centro);

    float ponto = 1.0 - step(
        min(tamanho.x, tamanho.y) * 0.5,
        max(distancia.x, distancia.y)
    );

    // Distribuicao de particulas
    float existe = step(0.40, random(id + 13.0));

    // Variacao delicada de brilho
    float brilho = 0.85 + 0.15 *
        sin(TIME * 0.7 + random(id) * 6.28);

    float alpha = ponto * existe * brilho * transparencia;

    COLOR = vec4(cor_particula.rgb, alpha);
}
