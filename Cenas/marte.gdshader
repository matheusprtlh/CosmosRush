
shader_type canvas_item;
render_mode unshaded, blend_mix;

// ====================================
// CAPTURA DA TELA
// ====================================
uniform sampler2D tela : hint_screen_texture, filter_nearest;

// ====================================
// FILTRO QUENTE DE MARTE
// ====================================
uniform float intensidade_filtro : hint_range(0.0, 1.0) = 0.85;
uniform float saturacao : hint_range(0.0, 2.0) = 1.25;
uniform float contraste : hint_range(0.5, 2.0) = 1.06;
uniform float brilho : hint_range(-0.2, 0.3) = 0.045;

uniform vec4 cor_laranja : source_color = vec4(1.0, 0.58, 0.24, 1.0);
uniform vec4 cor_dourada : source_color = vec4(1.0, 0.89, 0.55, 1.0);
uniform vec4 cor_rosa : source_color = vec4(1.0, 0.48, 0.38, 1.0);

uniform float forca_laranja : hint_range(0.0, 1.0) = 0.32;
uniform float forca_rosa : hint_range(0.0, 1.0) = 0.07;

// ====================================
// SOL NO CANTO SUPERIOR DIREITO
// ====================================
// Centro fora da tela: somente um
// pedaco do sol fica visivel.
uniform vec2 posicao_sol = vec2(1.03, -0.03);

uniform float forca_sol : hint_range(0.0, 2.0) = 1.10;
uniform float alcance_sol : hint_range(0.1, 3.0) = 0.75;

// ====================================
// RAIOS PIXELADOS
// ====================================
uniform vec2 resolucao = vec2(640.0, 360.0);
uniform float tamanho_pixel : hint_range(1.0, 16.0) = 3.0;

uniform float intensidade_raios : hint_range(0.0, 1.0) = 0.45;
uniform float quantidade_raios : hint_range(2.0, 40.0) = 14.0;
uniform float velocidade_raios : hint_range(0.0, 2.0) = 0.035;

// ====================================
// FUNCOES
// ====================================
float luminosidade(vec3 cor) {
    return dot(cor, vec3(0.299, 0.587, 0.114));
}

void fragment() {
    vec2 uv = SCREEN_UV;

    // Imagem original sem blur
    vec3 original = texture(tela, uv).rgb;
    vec3 cor = original;

    // Saturacao e contraste
    float cinza = luminosidade(cor);
    cor = mix(vec3(cinza), cor, saturacao);
    cor = (cor - 0.5) * contraste + 0.5;
    cor += vec3(brilho);

    // Atmosfera alaranjada
    cor = mix(
        cor,
        cor * cor_laranja.rgb + vec3(0.09, 0.045, 0.01),
        forca_laranja
    );

    // Leve tonalidade rosada
    cor = mix(
        cor,
        cor * cor_rosa.rgb + vec3(0.045, 0.012, 0.01),
        forca_rosa
    );

    // ====================================
    // ILUMINACAO SOLAR
    // ====================================
    float proporcao = resolucao.x / resolucao.y;

    vec2 direcao = uv - posicao_sol;
    direcao.x *= proporcao;

    float distancia = length(direcao);

    // Halo quente concentrado no canto
    float halo = exp(
        -distancia * distancia * 2.8 /
        max(alcance_sol, 0.1)
    );

    cor += cor_dourada.rgb * halo * forca_sol * 0.42;

    // ====================================
    // RAIOS SOLARES PIXELADOS
    // ====================================

    // Grade pixelada somente para a luz
    vec2 grade = max(
        resolucao / tamanho_pixel,
        vec2(1.0)
    );

    vec2 uv_pixel = (
        floor(uv * grade) + 0.5
    ) / grade;

    vec2 raio_dir = uv_pixel - posicao_sol;
    raio_dir.x *= proporcao;

    float angulo = atan(raio_dir.y, raio_dir.x);

    // Feixes com bordas quadradas
    float onda1 = sin(
        angulo * quantidade_raios +
        TIME * velocidade_raios
    );

    float onda2 = sin(
        angulo * quantidade_raios * 1.7 -
        TIME * velocidade_raios * 0.5 + 2.0
    );

    float feixe1 = step(0.72, onda1);
    float feixe2 = step(0.88, onda2);

    float feixes = max(
        feixe1,
        feixe2 * 0.45
    );

    // Raios diminuem ao se afastar
    float distancia_raio = length(raio_dir);

    float alcance = exp(
        -distancia_raio * distancia_raio *
        1.5 / max(alcance_sol, 0.1)
    );

    // Animacao quase imperceptivel
    float pulso = 0.94 + 0.06 *
        sin(TIME * 0.35);

    feixes *= alcance * pulso;

    // Aplica luz dourada dos raios
    cor += cor_dourada.rgb *
        feixes *
        intensidade_raios *
        0.55;

    // Iluminacao geral vinda de cima
    float luz_superior = pow(1.0 - uv.y, 2.0);
    cor += cor_dourada.rgb * luz_superior * 0.045;

    // Mistura com a imagem original
    cor = mix(original, cor, intensidade_filtro);

    COLOR = vec4(clamp(cor, 0.0, 1.0), 1.0);
}
