using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DynamicGlowingOrbs : MonoBehaviour
{
    [SerializeField] private Material _material;
    [SerializeField] private GameObject[] _objects;
    [SerializeField] private float _scaleFactor = 0.35f;
    [SerializeField] [Range(0, 1)] private float _glowIntensity = 1.0f;
    
    [Header("Colors")] 
    [ColorUsageAttribute(true, true)] 
    [SerializeField] private List<Color> _colors = new List<Color>();

    private List<SphereCollider> _colliders = new List<SphereCollider>();
    private List<Vector4> _positions = new List<Vector4>();
    private List<float> _sizes = new List<float>();
    private List<Matrix4x4> _rotationMatrices = new List<Matrix4x4>();
    
    
    void Start()
    {
        InitLists();
        _material.SetInt("_NumberOfObjects", _objects.Length);
    }

    void Update()
    {
        UpdateShaderUniforms();
        _material.SetFloat("_Intensity", _glowIntensity);
    }

    private void InitLists()
    {
        for (int i = 0; i < _objects.Length; i++)
        {
            var collider = _objects[i].GetComponent<SphereCollider>();
            collider.radius = _scaleFactor * 1.1f; // maybe need to fine tune this value
            _colliders.Add(collider);
            
            var pos3 = _objects[i].transform.position;
            _positions.Add(new Vector4(pos3.x, pos3.y, pos3.z));

            var size = _objects[i].transform.lossyScale.magnitude;
            _sizes.Add(size * _scaleFactor);
            
            var rot = _objects[i].transform.rotation;
            _rotationMatrices.Add(Matrix4x4.Rotate(rot));
        }
    }

    private void UpdateShaderUniforms()
    {
        for (int i = 0; i < _objects.Length; i++)
        {
            var pos3 = _objects[i].transform.position;
            _positions[i] = new Vector4(pos3.x, pos3.y, pos3.z, 1.0f);

            var scale = _objects[i].transform.localScale;
            _sizes[i] = scale.x * _scaleFactor;

            var rot = _objects[i].transform.rotation;
            _rotationMatrices[i] = Matrix4x4.Rotate(rot);
        }
        
        var posistionsArray = _positions.ToArray();
        var sizesArray = _sizes.ToArray();
        var rotationsArray = _rotationMatrices.ToArray();
        var colorsArray = _colors.ToArray();
        
        _material.SetVectorArray("_Positions", posistionsArray);
        _material.SetFloatArray("_Sizes", sizesArray);
        _material.SetMatrixArray("_Rotations", rotationsArray);
        _material.SetColorArray("_Colors", colorsArray);
    }
}
