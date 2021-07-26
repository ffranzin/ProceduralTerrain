
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Profiling;
using Utils.Analysis;

public class RenderCost : MonoBehaviour
{
    private Sampler sampler;
    private Analysis samplerTimers;

    void Start()
    {
        samplerTimers = new Analysis("Rendering.txt");
    }


    private void Update()
    {
        if (sampler == null || !sampler.isValid)
        {
            sampler = Sampler.Get("Gfx.WaitForPresentOnGfxThread");
        }

        if (sampler.isValid)
        {
            samplerTimers.AddData($"\nFrame:{Time.frameCount}\t{ (sampler.GetRecorder().elapsedNanoseconds / 1000000.0f).ToString("0.0000")}");
        }
    }


    private void OnDestroy()
    {
        samplerTimers?.SaveAnalysis();
    }
}
