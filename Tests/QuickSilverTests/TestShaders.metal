#include <metal_stdlib>
using namespace metal;

struct output {
    float4 position [[position]];
};

vertex output test_vs(uint vertex_id [[vertex_id]]) {
    return {
        float4(0.0)
    };
}

fragment half4 test_fs(output in [[stage_in]], constant float *halfWidth [[buffer(0)]]) {
    if (in.position.x < *halfWidth) {
        return half4(half3(1.0h / 3.0h), 1.0h);
    } else {
        return half4(half3(2.0h / 3.0h), 1.0h);
    }
}
