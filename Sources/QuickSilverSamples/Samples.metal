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
    float2 ndcPosition;
};

constant float2 trianglePositions[] = {
    float2(-0.5, -0.5),
    float2(0.0, 0.5),
    float2(0.5, -0.5)
};

vertex TriangleVaryings vfTriangle(uint vId [[vertex_id]]) {
    auto position = trianglePositions[vId];
    
    return {
        .position = float4(position, 0.5, 1.0),
        .ndcPosition = position
    };
}

fragment half4 ffTriangle(TriangleVaryings in [[stage_in]]) {
    return half4(half2(in.ndcPosition * 0.5 + 0.5), 0.0h, 0.0h);
}
