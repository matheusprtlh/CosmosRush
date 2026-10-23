
shader_type canvas_item;
render_mode unshaded, blend_mix;

// === MOVIMENTO ===
const float DURACAO = 25.0;

uniform float tamanho_inicial : hint_range(0.01, 0.3) = 0.035;
uniform float tamanho_final : hint_range(0.02, 0.5) = 0.15;

// === INSTABILIDADE DA ROCHA ===
uniform float intensidade_rotacao : hint_range(0.0, 1.0) = 0.22;
uniform float velocidade_rotacao : hint_range(0.0, 20.0) = 3.5;
uniform float intensidade_tremor : hint_range(0.0, 0.2) = 0.035;

// === FUNCOES ===
float hash21(vec2 p) {
    return fract(
        sin(dot(p, vec2(127.1, 311.7))) * 43758.5453
    );
}

float ruido2d(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));

    return mix(
        mix(a, b, f.x),
        mix(c, d, f.x),
        f.y
    );
}

float circulo(vec2 p, vec2 centro, float raio) {
    return 1.0 - step(raio, length(p - centro));
}

void fragment() {
    // === TRAJETORIA ===
    float progresso = clamp(TIME / DURACAO, 0.0, 1.0);

    vec2 inicio = vec2(1.05, -0.05);
    vec2 fim = vec2(0.12, 0.88);
    vec2 posicao = mix(inicio, fim, progresso);

    float crescimento = smoothstep(0.0, 1.0, progresso);

    float tamanho = mix(
        tamanho_inicial,
        tamanho_final,
        crescimento
    );

    // Mantem o meteoro circular
    vec2 aspecto = vec2(
        1.0,
        1.0 / max(
            TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x,
            0.001
        )
    );

    vec2 direcao = normalize((fim - inicio) * aspecto);
    vec2 perpendicular = vec2(-direcao.y, direcao.x);

    vec2 p = (UV - posicao) * aspecto / tamanho;

    // === ROTACAO E TREMOR INVOLUNTARIOS ===
    float angulo = (
        sin(TIME * velocidade_rotacao) * 0.7 +
        sin(TIME * velocidade_rotacao * 1.73) * 0.3
    ) * intensidade_rotacao;

    vec2 tremor = vec2(
        sin(TIME * 17.0) * 0.65 +
        sin(TIME * 29.0) * 0.35,

        cos(TIME * 21.0) * 0.65 +
        cos(TIME * 33.0) * 0.35
    ) * intensidade_tremor;

    float c = cos(angulo);
    float s = sin(angulo);

    mat2 rotacao = mat2(
        vec2(c, s),
        vec2(-s, c)
    );

    // Apenas a rocha gira e treme
    vec2 p_rocha = rotacao * (p - tremor);

    // === PIXEL ART 64x64 ===
    vec2 pixel = floor(p_rocha * 32.0) / 32.0;

    float distancia = length(pixel);
    float detalhe = ruido2d(pixel * 10.0);
    float borda = 0.78 + (detalhe - 0.5) * 0.09;

    float rocha = 1.0 - step(borda, distancia);

    // === TEXTURA ROCHOSA ===
    float manchas = ruido2d(pixel * 13.0);
    float rachaduras = ruido2d(pixel * 28.0);

    vec3 cor_rocha = vec3(0.22, 0.18, 0.19);

    cor_rocha = mix(
        cor_rocha,
        vec3(0.49, 0.34, 0.27),
        smoothstep(0.28, 0.75, manchas)
    );

    // Iluminacao da frente
    float luz = clamp(
        dot(
            normalize(pixel + vec2(0.001)),
            direcao
        ),
        -1.0,
        1.0
    );

    cor_rocha *= 0.82 + 0.25 * luz;

    // Regioes incandescentes
    float calor = smoothstep(
        0.0,
        0.8,
        dot(pixel, direcao)
    );

    cor_rocha = mix(
        cor_rocha,
        vec3(1.0, 0.36, 0.07),
        calor * 0.72
    );

    // Fissuras luminosas
    float fissura = step(0.83, rachaduras) * calor;

    cor_rocha = mix(
        cor_rocha,
        vec3(1.0, 0.72, 0.18),
        fissura * 0.55
    );

    // === CRATERAS ===
    float cratera1 = circulo(
        pixel,
        vec2(-0.24, -0.19),
        0.17
    );

    float cratera2 = circulo(
        pixel,
        vec2(0.19, 0.16),
        0.11
    );

    float cratera3 = circulo(
        pixel,
        vec2(-0.05, 0.32),
        0.09
    );

    float crateras = max(
        cratera1,
        max(cratera2, cratera3)
    );

    cor_rocha = mix(
        cor_rocha,
        vec3(0.13, 0.10, 0.12),
        crateras * 0.65
    );

    // ==================================
    // CAUDA DE FOGO PIXELADA
    // ==================================

    // A cauda nao acompanha a rotacao da rocha
    vec2 fogo_pixel = floor(p * 18.0) / 18.0;

    float longitudinal = dot(fogo_pixel, direcao);
    float lateral = dot(fogo_pixel, perpendicular);

    float comprimento = clamp(
        -longitudinal,
        0.0,
        7.0
    );

    float largura = mix(
        0.70,
        0.03,
        comprimento / 7.0
    );

    // Turbulencia em blocos
    vec2 celula_fogo = floor(
        vec2(
            comprimento * 8.0 - TIME * 6.0,
            lateral * 12.0
        )
    );

    float turbulencia = hash21(celula_fogo);

    float ondulacao = (
        turbulencia - 0.5
    ) * 0.45;

    float lateral_fogo = abs(lateral + ondulacao);

    // Contorno pixelado
    float mascara_cauda = 1.0 - step(
        largura,
        lateral_fogo
    );

    mascara_cauda *= 1.0 - step(
        7.0,
        comprimento
    );

    mascara_cauda *= step(
        longitudinal,
        -0.3
    );

    // Recortes quadrados
    float recorte = hash21(
        celula_fogo + vec2(17.0, 9.0)
    );

    mascara_cauda *= step(
        0.16,
        recorte
    );

    // === CAMADAS DO FOGO ===
    float centro_fogo = 1.0 - step(
        largura * 0.40,
        lateral_fogo
    );

    float fogo_amarelo = centro_fogo *
        (1.0 - step(3.2, comprimento));

    float fogo_laranja = mascara_cauda *
        (1.0 - step(5.2, comprimento));

    vec3 cor_cauda = vec3(
        0.72, 0.06, 0.015
    );

    cor_cauda = mix(
        cor_cauda,
        vec3(1.0, 0.34, 0.02),
        fogo_laranja
    );

    cor_cauda = mix(
        cor_cauda,
        vec3(1.0, 0.82, 0.15),
        fogo_amarelo
    );

    // Brilhos pixelados
    float brilho_fogo = step(
        0.84,
        hash21(celula_fogo + vec2(4.0, 13.0))
    );

    cor_cauda = mix(
        cor_cauda,
        vec3(1.0, 0.95, 0.42),
        brilho_fogo * fogo_amarelo
    );

    // === FAISCAS ===
    vec2 grade_particulas = floor(
        vec2(
            comprimento * 6.0 - TIME * 4.0,
            lateral * 10.0
        )
    );

    float particula = hash21(grade_particulas);

    float faisca = step(0.95, particula);

    faisca *= step(0.4, comprimento);
    faisca *= 1.0 - step(7.0, comprimento);

    faisca *= 1.0 - step(
        1.25,
        abs(lateral)
    );

    // === COMPOSICAO FINAL ===
    float alpha_fogo = max(
        mascara_cauda,
        faisca
    );

    vec3 cor_final = mix(
        cor_cauda,
        cor_rocha,
        rocha
    );

    cor_final = mix(
        cor_final,
        vec3(1.0, 0.55, 0.10),
        faisca * (1.0 - rocha)
    );

    float alpha = max(rocha, alpha_fogo);

    // Desaparece perto do destino
    alpha *= 1.0 - smoothstep(
        0.94,
        1.0,
        progresso
    );

    COLOR = vec4(cor_final, alpha);
}
