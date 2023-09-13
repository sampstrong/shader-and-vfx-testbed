using TMPro;
using UnityEngine;
using UnityEngine.Experimental.Audio;

public class FrameRateCounter : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI display;
    [SerializeField, Range(0.1f, 2f)] private float sampleDuration = 1f;

    private int frames;
    private float duration;

    private void Update()
    {
        float frameDuration = Time.unscaledDeltaTime;
        frames += 1;
        duration += frameDuration;
        if (duration >= sampleDuration)
        {
            display.SetText($"FPS\n{frames / duration:0}\n000\n000");
            frames = 0;
            duration = 0f;
        }
    }
}
