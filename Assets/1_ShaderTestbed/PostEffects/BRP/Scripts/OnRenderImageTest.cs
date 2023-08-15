using UnityEngine;

public class OnRenderImageTest : MonoBehaviour
{
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Debug.Log($"OnRenderImage, gameObject: {gameObject}");
        
        Graphics.Blit(src, dest);
    }
}
