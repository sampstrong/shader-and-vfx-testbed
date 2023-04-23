using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

public class AudioNoodle : MonoBehaviour
{
    [SerializeField] private Material _material;
    [SerializeField] private float _minSpeed = 1.0f;

    private Shader s;

    private float _customTime = 0.0f;

    public void ControlSpeed()
    {
        var speed = AudioVisualizeManager.Output_Volume * 10.0f + _minSpeed;
        _customTime += Time.deltaTime * speed;

        _material.SetFloat("_CustomTime", _customTime);
    }
}
