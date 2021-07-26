
using UnityEngine;


namespace Utils
{
    public static class CombineTextures
    {
        public static Texture2D CombineRGB_R(Texture2D albedo, Texture2D opacity, TextureFormat format, bool useMipmap = true)
        {
            Color32[] albedoColors = albedo.GetPixels32();
            Color32[] opacityColors = opacity.GetPixels32();

            if (albedoColors.Length != opacityColors.Length)
            {
                Debug.LogError("Textures must be the same size.");
                return null;
            }

            for (int i = 0; i < albedoColors.Length; i++)
            {
                albedoColors[i].a = opacityColors[i].r;
            }

            Texture2D texture = new Texture2D(albedo.width, albedo.height, format, useMipmap);
            texture.SetPixels32(albedoColors);
            texture.Apply();

            return texture;
        }
    }
}