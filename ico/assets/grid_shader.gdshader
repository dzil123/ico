shader_type spatial;
render_mode unshaded;
render_mode skip_vertex_transform;

uniform float low_range : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float high_range : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform vec4 outer_color : hint_color = vec4(vec3(0.4), 1.0);
uniform vec4 inner_color : hint_color = vec4(vec3(0.2), 1.0);
uniform bool toggle_outer = false;
uniform vec3 highlight_tri_pos;
uniform vec3 highlight_cart_pos;
uniform bool enable_highlight_tri_pos = true;
uniform sampler2D tex_colors : hint_black;
uniform sampler2D tex_data : hint_black;
uniform vec2 tex_data_size;
uniform vec2 tex_data_offset;
uniform float Z_exp : hint_range(-10.0, 2.0) = 0.0;
uniform float time = 0.0;

varying flat vec3 tri_pos;
varying flat vec2 global_data;
varying flat float scale;

const float HEIGHT = sqrt(3.0) / 6.0;
const vec2 pt1 = vec2(-0.5, HEIGHT);
const vec2 pt2 = vec2(0, -2.0 * HEIGHT);
const vec2 pt3 = vec2(0.5, HEIGHT);

vec2 tri_center(vec3 tri) {
    tri = round(tri);
    return vec2(0.5 * tri.x + -0.5 * tri.z,
                -sqrt(3.0) / 6.0 * tri.x + sqrt(3.0) / 3.0 * tri.y - sqrt(3.0) / 6.0 * tri.z);
}

vec3 pick_tri(vec2 pos) {
    return vec3(ceil(1.0 * pos.x - sqrt(3.0) / 3.0 * pos.y),
                floor(sqrt(3.0) * 2.0 / 3.0 * pos.y) + 1.0,
                ceil(-1.0 * pos.x - sqrt(3.0) / 3.0 * pos.y));
}

vec3 tex_color(int i) {
    if (i < 0) {
        return vec3(0.0);
    } else if (i >= 8) {
        return vec3(0.5);
    }

    float x = (float(i) * 2.0 + 1.0) / (2.0 * 8.0);
    vec4 col = texture(tex_colors, vec2(x, 0.8));

    return col.rgb;
}

vec2 read_data(bool pointy) {
    vec2 raw_pos = tri_pos.xy + tex_data_offset;
    vec2 pos = (raw_pos * 2.0 + 1.0) / (2.0 * tex_data_size);  // scaled to 0 - 1
    vec4 col = texture(tex_data, pos);
    vec2 data = pointy ? col.rg : col.ba;
    return round(data * 255.0);
}

float s01(float x) { return x * 0.5 + 0.5; }
float sin01(float x) { return s01(sin(x)); }

void vertex() {
    mat4 mat = WORLD_MATRIX;
    vec2 world_pos = vec2(mat[3][0], mat[3][2]);  // model world position
    tri_pos = pick_tri(world_pos * vec2(1, -1) - 0.25);
    ivec3 i_tri_pos = ivec3(round(tri_pos));
    bool pointy = i_tri_pos.x + i_tri_pos.y + i_tri_pos.z == 2;
    global_data = read_data(pointy);

    scale = 1.0;
    scale = sin(TIME * 3.14) * 0.25 + 0.9;
    scale = clamp(scale, 0.0, 1.0);
    // scale = fract(TIME / 4.0) * 2.0;
    // scale = s01(sin(TIME + tri_pos.x) * sin(TIME + 2.0 + tri_pos.y));
    // float d = distance(world_pos, highlight_cart_pos.xz);
    // scale = s01(sin(d + -1.5 * TIME));
    // scale = s01(scale);

    ivec2 data = ivec2(global_data);

    // center the triangle as it scales
    VERTEX.xz *= scale;
    VERTEX = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
    VERTEX.xz += (1.0 - scale) * vec2(-0.25, sqrt(3.0) / 12.0) * vec2(1, pointy ? 1. : -1.);
    VERTEX = (INV_CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz;

    NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

float calc_edge(vec3 bary, float low_rng, float high_rng) {
    float sum = bary.x + bary.y + bary.z;
    if (sum < 0.9 || sum > 1.1) {
        return 0.0;
    }

    vec3 k = fwidth(bary) / 2.0;  // 2 is optimal because p-k,p+k

    low_rng = clamp(low_rng, 0.0, 1.0);
    high_rng = clamp(high_rng, 0.0, 1.0);

    vec3 low_split = smoothstep((low_rng / 3.0) - k, (low_rng / 3.0) + k, bary);
    float low = low_split.x * low_split.y * low_split.z;

    vec3 high_split = smoothstep((high_rng / 3.0) - k, (high_rng / 3.0) + k, bary);
    float high = high_split.x * high_split.y * high_split.z;

    float edge = 1.0;
    if (low_rng > 0.0) {
        edge *= low;
    }

    if (high_rng < 1.0) {
        edge *= (1.0 - high);
    }

    return edge;
}

void fragment() {
    vec3 bary = COLOR.xyz;  // triangle barycentric coordinates
    ivec2 data = ivec2(global_data);

    if (data.y > 0) {
        if (data.y == 255) {
            discard;
        }
    }

    float d = distance(vec3(1.0 / 3.0), bary);
    vec2 norm = bary.x * pt1 + bary.y * pt2 + bary.z * pt3;
    float a = atan(norm.y, norm.x);
    float t = fract(TIME * 0.5);
    t = mix(-6.28, 6.28, t) * 0.5;
    float k = 0.05 * sin(10.0 * a + t);
    k = 0.0;

    float Z = exp(Z_exp);
    float Z_scale = (pow(bary.x, Z) + pow(bary.y, Z) + pow(bary.z, Z));
    bary = pow(bary, vec3(Z)) / Z_scale;

    bool shrink_center = true;  // shrink center or shrink edges

    float low = low_range;
    low = low / Z_scale;
    // low = pow(low, Z);
    low = low / scale;

    float high = high_range;
    high = high / Z_scale;
    // high = pow(high, Z);
    high = high / scale;

    float edge;
    if (shrink_center) {
        edge = calc_edge(bary, low_range / scale, high_range / scale);
        edge = calc_edge(bary, k + low, k + high);
    } else {
        bary = (bary - (1.0 / 3.0)) * scale + (1.0 / 3.0);
        edge = calc_edge(bary, low_range, high_range);
    }

    if (toggle_outer) {
        edge = 1.0 - edge;
    }

    vec3 new_inner_color = inner_color.rgb;

    if (data.r > 0) {
        new_inner_color = tex_color(data.r - 1);
    }

    vec3 color = mix(outer_color.rgb, new_inner_color, edge).rgb;

    if (enable_highlight_tri_pos && distance(tri_pos, highlight_tri_pos) < 0.1) {
        color = vec3(1, 0, 0);
    }

    ALBEDO = color;

    // ALBEDO = vec3(d);
    // ALBEDO = vec3(step(0.3 + 0.05 * sin(10.0 * a + t), d));
    // ALBEDO = vec3(0.3 + 0.05 * sin(10.0 * a + t));
    // ALBEDO = pow(bary, vec3(3.0));
}
