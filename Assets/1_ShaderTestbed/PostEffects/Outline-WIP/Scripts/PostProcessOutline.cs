using System;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(PostProcessOutlineRenderer), PostProcessEvent.AfterStack, "Outline")]
public class PostProcessOutline : PostProcessEffectSettings
{
    public FloatParameter thickness = new FloatParameter { value = 1f };
    public FloatParameter depthMin = new FloatParameter { value = 0f };
    public FloatParameter depthMax = new FloatParameter { value = 1f };
}
