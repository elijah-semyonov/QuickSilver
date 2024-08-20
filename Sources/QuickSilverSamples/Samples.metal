//
//  File.metal
//  QuickSilver
//
//  Created by Elijah Semyonov on 17/08/2024.
//

#include <metal_stdlib>

using namespace metal;

struct TriangleVaryings {
    float4 position [[position]];
    float3 color;
};

constant float2 trianglePositions[] = {
    float2(-0.8, -0.8),
    float2(0.0, 0.8),
    float2(0.8, -0.8)
};

constant float3 triangleColors[] = {
    float3(1.0, 0.0, 0.0),
    float3(0.0, 1.0, 0.0),
    float3(0.0, 0.0, 1.0)
};

vertex TriangleVaryings vfTriangle(uint vId [[vertex_id]]) {
    auto position = trianglePositions[vId];
    auto color = triangleColors[vId];
    
    return {
        .position = float4(position, 0.5, 1.0),
        .color = color
    };
}

fragment half4 ffTriangle(TriangleVaryings in [[stage_in]]) {
    return half4(half3(in.color), 1.0h);
}
