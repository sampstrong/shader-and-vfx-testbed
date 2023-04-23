using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class NorthernLightsAudio : MonoBehaviour
{
    [SerializeField] private VisualEffect _effect;
    public void SetHeight()
    {
        var newThickness = 2f + AudioVisualizeManager.Output_Volume;
        _effect.SetFloat("Thickness", newThickness);
    }
}
