using UnityEngine;

[ExecuteInEditMode]
public class SingularInteractiveRaymarcher : MonoBehaviour
{
    [SerializeField] private Material _material;
    [SerializeField] private GameObject _object;
    [SerializeField] private float _scaleFactor = 0.35f;

    private SphereCollider _collider;
    private Vector4 _objectPosition;
    private float _objectRadius;
    
    void Start()
    {
        InitCollider();   
    }

    void Update()
    {
        UpdateShaderUniforms();
    }

    private void InitCollider()
    {
        _collider = _object.GetComponent<SphereCollider>();
        _collider.radius = _scaleFactor;
    }

    private void UpdateShaderUniforms()
    {
        var pos3 = _object.transform.position;
        _objectPosition = new Vector4(pos3.x, pos3.y, pos3.z, 1.0f);

        var scale = _object.transform.localScale;
        _objectRadius = scale.x * _scaleFactor;
        
        _material.SetVector("_Position", _objectPosition);
        _material.SetFloat("_Radius", _objectRadius);
    }
}
