
shader_type canvas_item;
render_mode unshaded, blend_mix;

// CAPTURA DA TELA
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// AJUSTES PRINCIPAIS
uniform float saturacao : hint_range(0.0, 2.0) = 1.22;
uniform float brilho : hint_range(-0.2, 0.3) = 0.055;
uniform float contraste : hint_range(0.5, 2.0) = 1.04;
uniform float intensidade_filtro : hint_range(0.0, 1.0) = 0.45;

// CORES DA ATMOSFERA
uniform vec4 amarelo_sol : source_color = vec4(1.0, 0.88, 0.52, 1.0);
uniform vec4 rosa_suave : source_color = vec4(1.0, 0.68, 0.80, 1.0);

// INTENSIDADE DAS CORES
uniform float intensidade_amarelo : hint_range(0.0, 1.0) = 0.10;
uniform float intensidade_rosa : hint_range(0.0, 1.0) = 0.055;

// LUZ SUPERIOR
uniform float luz_ambiente : hint_range(0.0, 1.0) = 0.08;

void fragment() {
    vec2 uv = SCREEN_UV;

    // COR ORIGINAL DO JOGO
    vec3 original = texture(screen_texture, uv).rgb;
    vec3 cor = original;

    // AUMENTO DA SATURACAO
    float luminancia = dot(
        cor,
        vec3(0.299, 0.587, 0.114)
    );

    cor = mix(
        vec3(luminancia),
        cor,
        saturacao
    );

    // CONTRASTE LEVE
    cor = (cor - 0.5) * contraste + 0.5;

    // ILUMINACAO MAIS CLARA
    cor += vec3(brilho);

    // TONS DOURADOS E ROSADOS
    float luz = clamp(
        dot(original, vec3(0.299, 0.587, 0.114)),
        0.0,
        1.0
    );

    // AMARELO MAIS PRESENTE NA PARTE SUPERIOR
    float dourado = (1.0 - uv.y) * 0.6 + 0.4;

    // ROSA SUAVE DISTRIBUIDO PELO CENARIO
    float rosa = 0.5 + 0.5 * uv.x;

    cor = mix(
        cor,
        cor * amarelo_sol.rgb + vec3(0.025, 0.015, 0.0),
        intensidade_amarelo * dourado
    );

    cor = mix(
        cor,
        cor * rosa_suave.rgb + vec3(0.018, 0.0, 0.012),
        intensidade_rosa * rosa
    );

    // BRILHO SUAVE NAS REGIOES CLARAS
    float iluminacao = smoothstep(0.25, 0.9, luz);

    cor += vec3(1.0, 0.92, 0.78)
        * iluminacao
        * luz_ambiente
        * 0.25;

    // MISTURA COM A IMAGEM ORIGINAL
    cor = mix(
        original,
        cor,
        intensidade_filtro
    );

    COLOR = vec4(
        clamp(cor, 0.0, 1.0),
        1.0
    );
}
