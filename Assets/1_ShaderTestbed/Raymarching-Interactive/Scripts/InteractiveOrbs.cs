using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting.Dependencies.NCalc;
using UnityEngine;
using UnityEngine.VFX;

public class InteractiveOrbs : MonoBehaviour
{
    [SerializeField] private Shader _shader;
    [SerializeField] private Orb _orbPrefab;
    [SerializeField] [Range(0, 1)] private float _glowAmount; 
    [SerializeField] private float _scaleFactor = 0.35f;
    [SerializeField] private int _currentBand = 1;

    [SerializeField] private VisualEffect _electricArc;

    [Header("Colors")] 
    [ColorUsageAttribute(true, true)] 
    [SerializeField] private Color _band0Color;
    [ColorUsageAttribute(true, true)] 
    [SerializeField] private Color _band1Color;
    [ColorUsageAttribute(true, true)] 
    [SerializeField] private Color _band2Color;
    [ColorUsageAttribute(true, true)] 
    [SerializeField] private Color _band3Color;
    [ColorUsageAttribute(true, true)] 
    [SerializeField] private Color _band4Color;
    [ColorUsageAttribute(true, true)] 
    [SerializeField] private Color _band5Color;
    [ColorUsageAttribute(true, true)] 
    [SerializeField] private Color _band6Color;
    [ColorUsageAttribute(true, true)] 
    [SerializeField] private Color _band7Color;


    private List<Material> _materials = new List<Material>();
    private List<Orb> _orbs = new List<Orb>();
    
    void Start()
    {
        for (int i = 0; i < 5; i++)
        {
            AddOrb(Random.Range(0, 7));
        }
    }

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
            AddOrb(_currentBand);
        
        UpdateShader();
        UpdateArc();
    }
    
    private void AddOrb(int band)
    {
        var orb = Instantiate(_orbPrefab, GetRandV3(2f), Quaternion.identity);
        var mat = SetUpMaterial(orb);
        mat.SetColor("_GlowColor", GetColor(band));
        orb.Renderer.material = mat;
        _materials.Add(mat);
        _orbs.Add(orb);
    }

    private Material SetUpMaterial(Orb orb)
    {
        var mat = new Material(_shader);
        mat.SetVector("_Position", orb.transform.position);
        mat.SetFloat("_Size", orb.transform.lossyScale.magnitude * _scaleFactor);
        mat.SetMatrix("_Rotation", Matrix4x4.Rotate(orb.transform.rotation));

        return mat;
    }

    private void UpdateShader()
    {
        for (int i = 0; i < _orbs.Count; i++)
        {
            _materials[i].SetFloat("_Intensity", _glowAmount * 2f);
            _materials[i].SetVector("_Position", _orbs[i].transform.position);
            _materials[i].SetFloat("_Size", _orbs[i].transform.lossyScale.magnitude * _scaleFactor);
            _materials[i].SetMatrix("_Rotation", Matrix4x4.Rotate(_orbs[i].transform.rotation));
        }
    }

    private Color GetColor(int band)
    {
        switch (band)
        {
            case 0:
                return _band0Color;
            case 1:
                return _band1Color;
            case 2:
                return _band2Color;
            case 3:
                return _band3Color;
            case 4:
                return _band4Color;
            case 5:
                return _band5Color;
            case 6:
                return _band6Color;
            case 7:
                return _band7Color;
            default:
                return _band0Color;
        }
    }

    private Vector3 GetRandV3(float range)
    {
        var x = (Random.value * 2f - 1f) * range;
        var y = (Random.value * 2f - 1f) * range;
        var z = (Random.value * 2f - 1f) * range;

        return new Vector3(x, y, z);
    }

    private void UpdateArc()
    {
        _electricArc.SetVector3("Pos1", _orbs[1].transform.position);
        _electricArc.SetVector3("Pos2", _orbs[2].transform.position);
    }
}
