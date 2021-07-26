using System.Collections.Generic;
using UnityEngine;


public class TerrainTexture : MonoBehaviour
{
    [SerializeField] private List<Texture2D> albedos;
    [SerializeField] private List<Texture2D> normals;
    [SerializeField] private List<Texture2D> AO;
    [SerializeField] private List<Texture2D> specular;
    [SerializeField] private List<Texture2D> smoothness;

    private Texture2DArray texArrayAlbedo;
    private Texture2DArray texArrayNormal;
    private Texture2DArray texArrayAO;
    private Texture2DArray texArraySpecular;
    private Texture2DArray texArraySmoothness;

    public void SetTerrainTexturesOnMaterial(Material material)
    {
        if(texArrayAlbedo == null || texArrayNormal == null || texArrayAO == null || texArraySpecular == null || texArraySmoothness == null)
        {
            CreateTextureArrays();
        }

        material.SetTexture("_TerrainTextureArrayAlbedo", texArrayAlbedo);
        material.SetTexture("_TerrainTextureArrayNormal", texArrayNormal);
        material.SetTexture("_TerrainTextureArrayAO", texArrayAO);
        material.SetTexture("_TerrainTextureArraySpecular", texArraySpecular);
        material.SetTexture("_TerrainTextureArraySmoothness", texArraySmoothness);
    }


    private void CreateTextureArrays()
    {
        int textureCounter = albedos.Count;
        int texSize = albedos[0].width;
        int mipCount = albedos[0].mipmapCount;

        texArrayAlbedo = new Texture2DArray(texSize, texSize, textureCounter, albedos[0].format, true, false);
        texArrayNormal = new Texture2DArray(texSize, texSize, textureCounter, normals[0].format, true, true);
        texArrayAO = new Texture2DArray(texSize, texSize, textureCounter, AO[0].format, true, true);
        texArraySpecular = new Texture2DArray(texSize, texSize, textureCounter, specular[0].format, true, true);
        texArraySmoothness = new Texture2DArray(texSize, texSize, textureCounter, smoothness[0].format, true, true);

        texArrayAlbedo.filterMode = FilterMode.Trilinear;
        texArrayNormal.filterMode = FilterMode.Trilinear;
        texArrayAO.filterMode = FilterMode.Trilinear;
        texArraySpecular.filterMode = FilterMode.Trilinear;
        texArraySmoothness.filterMode = FilterMode.Trilinear;

        for (int i = 0; i < textureCounter; i++)
        {
            for (int mip = 0; mip < mipCount; mip++)
            {
                Graphics.CopyTexture(albedos[i], 0, mip, texArrayAlbedo, i, mip);
                Graphics.CopyTexture(normals[i], 0, mip, texArrayNormal, i, mip);
                Graphics.CopyTexture(AO[i], 0, mip, texArrayAO, i, mip);
                Graphics.CopyTexture(specular[i], 0, mip, texArraySpecular, i, mip);
                Graphics.CopyTexture(smoothness[i], 0, mip, texArraySmoothness, i, mip);
            }
        }

        texArrayAlbedo.Apply(false, true);
        texArrayNormal.Apply(false, true);
        texArrayAO.Apply(false, true);
        texArraySpecular.Apply(false, true);
        texArraySmoothness.Apply(false, true);
    }
}
