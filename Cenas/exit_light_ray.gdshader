shader_type canvas_item;
render_mode unshaded, blend_add;

// White, soft light ray moving continuously toward the exit.
// Apply to a transparent ColorRect inside an exit marker scene.
uniform vec4 light_color : source_color = vec4(1.0, 1.0, 1.0, 0.85);
uniform vec2 direction = vec2(1.0, 0.0);
uniform float speed : hint_range(0.0, 4.0) = 0.7;
uniform float beam_width : hint_range(0.02, 1.0) = 0.24;
uniform float softness : hint_range(0.02, 1.0) = 0.34;
uniform float intensity : hint_range(0.0, 3.0) = 1.3;

void fragment() {
    vec2 dir = direction;
    if (length(dir) < 0.001) {
        dir = vec2(1.0, 0.0);
    }
    dir = normalize(dir);
    vec2 cross_dir = vec2(-dir.y, dir.x);
    vec2 centered = UV - vec2(0.5);

    float along = dot(centered, dir);
    float across = dot(centered, cross_dir);
    float half_extent = 0.5 * (abs(dir.x) + abs(dir.y));
    float phase = fract(TIME * speed);
    float center = mix(-half_extent - softness, half_extent + softness, phase);

    float transverse = exp(-3.0 * pow(across / max(beam_width, 0.001), 2.0));
    float longitudinal = exp(-3.0 * pow((along - center) / max(softness, 0.001), 2.0));
    float strength = transverse * longitudinal * intensity;
    float alpha = clamp(strength * light_color.a, 0.0, 1.0);
    COLOR = vec4(light_color.rgb * alpha, alpha);
}
