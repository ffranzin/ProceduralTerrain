using System;
using UnityEngine;

namespace MyTerrain
{
    public enum NoiseType { Simplex = 0, Gradient = 1, Ridgesimplex = 2, Ridgegradient = 3 }

    [Serializable]
    public struct NoiseParams
    {
        public NoiseType noiseType;
        public Vector2 offset;
        [Range(1, 8)] public int octaves;
        [Range(0, 5)] public float frequency;
        [Range(0, 5)] public float lacunarity;
        [Range(0, 5)] public float gain;
        [Range(-5, 5)] public float amp;
        [Range(-5000, 5000)] public float heightMultiplier;
        [Range(-5000, 5000)] public float heightOffset;
    }
}