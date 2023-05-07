using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class InteractiveRaymarcher : MonoBehaviour
{
    public GameObject[] Objects => _objects;
    
    [SerializeField] private Material _material;
    [SerializeField] private GameObject[] _objects;
    [SerializeField] private float _scaleFactor = 0.35f;
    
    private Vector4[] _objectPositions;
    private Vector4[] _objectScales;
    private SphereCollider[] _colliders;

    void Start()
    {
        _objectPositions = new Vector4[_objects.Length];
        _objectScales = new Vector4[_objects.Length];
        _colliders = new SphereCollider[_objects.Length];
        
        InitColliders();
        UpdateShaderUniforms();
    }
    
    void Update()
    {
        UpdateShaderUniforms();
    }

    private void InitColliders()
    {
        for (int i = 0; i < _objects.Length; i++)
        {
            _colliders[i] = _objects[i].GetComponent<SphereCollider>();
            _colliders[i].radius = _scaleFactor;
        }
    }

    private void UpdateShaderUniforms()
    {
        for (int i = 0; i < _objects.Length; i++)
        {
            // update positions
            var pos = _objects[i].transform.position;
            _objectPositions[i] = new Vector4(pos.x, pos.y, pos.z, 1.0f);
            
            // update scales
            var scale = _objects[i].transform.localScale * _scaleFactor;
            _objectScales[i] = new Vector4(scale.x, scale.y, scale.z, 1.0f);
        }
        
        _material.SetVectorArray("_Positions", _objectPositions);
        _material.SetVectorArray("_Sizes", _objectScales);
        _material.SetInt("_NumberOfObjects", _objects.Length);
    }
    
    // more efficient to run this code within a singular loop above
    private void SetPositions()
    {
        for (int i = 0; i < _objects.Length; i++)
        {
            var pos = _objects[i].transform.position;

            _objectPositions[i] = new Vector4(pos.x, pos.y, pos.z, 1.0f);
        }
        
        _material.SetVectorArray("_Positions", _objectPositions);
    }

    // more efficient to run this code within a singular loop above
    private void SetScales()
    {
        for (int i = 0; i < _objects.Length; i++)
        {
            var scale = _objects[i].transform.localScale * _scaleFactor;

            _objectScales[i] = new Vector4(scale.x, scale.y, scale.z, 1.0f);
        }
        
        _material.SetVectorArray("_Scales", _objectScales);
    }

   
}
