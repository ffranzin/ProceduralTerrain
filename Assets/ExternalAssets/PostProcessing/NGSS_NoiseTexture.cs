using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class NGSS_NoiseTexture : MonoBehaviour
{
    public Texture noiseTex;
    [Range(0f, 1f)]
    public float noiseScale = 1f;

    private bool isTextureSet = false;

    void Update()
    {
        Shader.SetGlobalFloat("NGSS_NOISE_TEXTURE_SCALE", noiseScale);
        if (isTextureSet || noiseTex == null) { return; }
        Shader.SetGlobalTexture("NGSS_NOISE_TEXTURE", noiseTex); isTextureSet = true;
    }
}
