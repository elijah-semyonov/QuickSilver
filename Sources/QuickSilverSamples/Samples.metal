//
//  File.metal
//  QuickSilver
//
//  Created by Elijah Semyonov on 17/08/2024.
//

#include <metal_stdlib>

using namespace metal;

static float linearFloatFromSrgb(float value) {
    if (value <= 0.04045) {
        return value / 12.92;
    } else {
        return pow((value + 0.055) / 1.055, 2.4);
    }
}

static float3 linearFloat3FromSrgb(float3 value) {
    return float3(linearFloatFromSrgb(value.x),
                  linearFloatFromSrgb(value.y),
                  linearFloatFromSrgb(value.z));
}

struct TriangleVaryings {
    float4 position [[position]];
    float3 color;
};

constant float2 trianglePositions[] = {
    float2(-0.8, -0.8),
    float2(0.0, 0.8),
    float2(0.8, -0.8)
};

vertex TriangleVaryings vfTriangle
(
 uint vId [[vertex_id]],
 constant packed_float3 *colors [[buffer(0)]]
) {
    auto position = trianglePositions[vId];
    auto color = linearFloat3FromSrgb(colors[vId]);
    
    return {
        .position = float4(position, 0.5, 1.0),
        .color = color
    };
}

fragment half4 ffTriangle
(
 TriangleVaryings in [[stage_in]]
) {
    return half4(half3(in.color), 1.0h);
}
