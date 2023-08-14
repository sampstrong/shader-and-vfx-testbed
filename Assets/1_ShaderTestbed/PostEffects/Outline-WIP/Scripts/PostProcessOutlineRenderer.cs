using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public class PostProcessOutlineRenderer : PostProcessEffectRenderer<PostProcessOutline>
{
    public static RenderTexture outlineRenderTexture;

    public override DepthTextureMode GetCameraFlags()
    {
        return DepthTextureMode.Depth;
    }
    
    public override void Render(PostProcessRenderContext context)
    {
        PropertySheet sheet = context.propertySheets.Get(Shader.Find("Hidden/Outline"));
        sheet.properties.SetFloat("_Thickness", settings.thickness);
        sheet.properties.SetFloat("_MinDepth", settings.depthMin);
        sheet.properties.SetFloat("_MaxDepth", settings.depthMax);

        if (outlineRenderTexture == null ||
            outlineRenderTexture.width != Screen.width ||
            outlineRenderTexture.height != Screen.height)
        {
            outlineRenderTexture = new RenderTexture(Screen.width, Screen.height, 24);
            context.camera.targetTexture = outlineRenderTexture;
        }
        
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
