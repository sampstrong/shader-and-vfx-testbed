using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

public class AudioNoodle : MonoBehaviour
{
    [SerializeField] private Material _material;
    [SerializeField] private float _minSpeed = 1.0f;

    [SerializeField] private bool _useAudio = true;

    private float _customTime = 0.0f;

    public void ControlSpeed()
    {
        if (_useAudio)
        {
            var speed = AudioVisualizeManager.Output_Volume * 10.0f + _minSpeed;
            _customTime += Time.deltaTime * speed;
        }
        else
        {
            _customTime += Time.deltaTime;
        }
        

        _material.SetFloat("_CustomTime", _customTime);
    }
}
