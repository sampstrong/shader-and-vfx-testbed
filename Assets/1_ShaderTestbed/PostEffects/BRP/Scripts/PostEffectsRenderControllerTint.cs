using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class PostEffectsRenderControllerTint : MonoBehaviour
{
    [SerializeField] private Color _tintColor;
    [SerializeField] private Shader _postShader;
    private Material _postMaterial;
    private static readonly int TintColor = Shader.PropertyToID("_TintColor");

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Debug.Log("Tint");
        
        // create a new material if one doesnt exist
        if (!_postMaterial) _postMaterial = new Material(_postShader);
        
        // create a render texture that we can modify
        // better than new RenderTexture because it manages the memory for you
        RenderTexture renderTexture = RenderTexture.GetTemporary(
            src.width,
            src.height,
            0,
            src.format
        );
        
        _postMaterial.SetColor(TintColor, _tintColor);
        
        // copies one render texture to another
        // option to add a material in the process
        Graphics.Blit(src, renderTexture, _postMaterial);
        Graphics.Blit(renderTexture, dest);
        
        // release texture from memory
        RenderTexture.ReleaseTemporary(renderTexture);
    }
}
