// using UnityEngine;
// using UnityEngine.Rendering.PostProcessing;
//
// public class PostProcessOutlineComposite : PostProcessEffectRenderer<PostProcessComposite>
// {
//     public override void Render(PostProcessRenderContext context)
//     {
//         var sheet = context.propertySheets.Get(Shader.Find("Hidden/OutlineComposite"));
//         sheet.properties.SetColor("_Color", settings.color);
//
//         if (PostProcessOutlineRenderer.outlineRenderTexture != null)
//         {
//             sheet.properties.SetTexture("_OutlineTex", PostProcessOutlineRenderer.outlineRenderTexture);
//         }
//
//         context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
//     }
// }
