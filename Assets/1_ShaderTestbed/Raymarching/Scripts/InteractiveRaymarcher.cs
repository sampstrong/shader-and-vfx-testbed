using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class InteractiveRaymarcher : MonoBehaviour
{
    [SerializeField] private Material _material;
    [SerializeField] private GameObject[] _objects;

    private Vector4[] _objectPositions;

    void Start()
    {
        _objectPositions = new Vector4[_objects.Length];
        SetPositions();
        
        _material.SetInt("_NumberOfSpheres", _objects.Length);
    }
    
    void Update()
    {
        SetPositions();
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
}
