using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class InteractiveRaymarcher : MonoBehaviour
{
    [SerializeField] private Material _material;
    [SerializeField] private GameObject[] _objects;

    private Vector4[] _objectPositions;
    private Vector4[] _objectScales;

    void Start()
    {
        _objectPositions = new Vector4[_objects.Length];
        _objectScales = new Vector4[_objects.Length];
        
        SetNumber();
        SetPositions();
        SetScales();
    }
    
    void Update()
    {
        SetNumber();
        SetPositions();
        SetScales();
    }

    private void SetNumber()
    {
        _material.SetInt("_NumberOfSpheres", _objects.Length);
    }
    
    private void SetPositions()
    {
        for (int i = 0; i < _objects.Length; i++)
        {
            var pos = _objects[i].transform.position;

            _objectPositions[i] = new Vector4(pos.x, pos.y, pos.z, 1.0f);
        }
        
        _material.SetVectorArray("_Positions", _objectPositions);
    }

    private void SetScales()
    {
        for (int i = 0; i < _objects.Length; i++)
        {
            var scale = _objects[i].transform.localScale * 0.4f;

            _objectScales[i] = new Vector4(scale.x, scale.y, scale.z, 1.0f);
        }
        
        _material.SetVectorArray("_Scales", _objectScales);
    }
}
