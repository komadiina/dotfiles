//!HOOK MAIN
//!BIND HOOKED
//!DESC animated wallpaper: gentle warp + drifting sheen

// mpv/libplacebo user shader. `frame` is the render frame counter;
// the launcher pins the source to 30fps, so this converts to seconds.

vec4 hook() {
    float t = float(frame) / 30.0;
    vec2 uv = HOOKED_pos;

    // slow rippling displacement
    vec2 warp = vec2(
        sin(uv.y * 36.0 + t * 0.1),
        cos(uv.x * 18.0 + t * 0.50)
    ) * 0.005;

    vec4 c = HOOKED_tex(clamp(uv + warp, 0.0, 1.0));

    // diagonal sheen sweeping across the image
    float sheen = sin((uv.x + uv.y) * 2.0 - t * 0.35) * 0.5 + 0.85;
    c.rgb *= 0.96 + 0.08 * sheen;

    return c;
}
