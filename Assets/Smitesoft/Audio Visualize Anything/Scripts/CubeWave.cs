using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class CubeWave : MonoBehaviour
{
    [SerializeField] private VisualEffect _effect;
    [SerializeField] private float _minSpeed = 0.05f;
    
    public void AddSpeed()
    {
        var newSpeed = AudioVisualizeManager.Output_Volume + _minSpeed;
        _effect.SetFloat("Speed", newSpeed);
    }
}
