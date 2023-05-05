using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

public class RandomMovement : MonoBehaviour
{
    [SerializeField] private InteractiveRaymarcher _raymarcher;
    [SerializeField] private float xBounds;
    [SerializeField] private float yBounds;
    [SerializeField] private float zBounds;
    [SerializeField] private float _velocityMultiplier = 1.0f;
    [SerializeField] private float _minVelocity = 0.1f;
    [SerializeField] private float _minScale = 0.2f;
    [SerializeField] private float _maxScale = 2.5f;
    
    private Rigidbody[] _rigidbodies;
    private Vector3[] _startingVelocities;
    private Vector3 _origin;
    private Vector3 _baseScale;

    void Start()
    {
        InitRigidbodies();
        _origin = new Vector3(0, 0, 0);
        _baseScale = new Vector3(1, 1, 1);
    }
    
    void Update()
    {
        UpdateRigidbodies();
        UpdateScales();
    }
    
    private void InitRigidbodies()
    {
        _rigidbodies = new Rigidbody[_raymarcher.Objects.Length];
        _startingVelocities = new Vector3[_raymarcher.Objects.Length];
        
        for (int i = 0; i < _raymarcher.Objects.Length; i++)
        {
            _rigidbodies[i] = _raymarcher.Objects[i].GetComponent<Rigidbody>();
            _rigidbodies[i].useGravity = false;
            _startingVelocities[i] = HelperMethods.GetRandomVec3() * _velocityMultiplier;
            _rigidbodies[i].velocity = _startingVelocities[i];
        }
    }

    private void UpdateRigidbodies()
    {
        foreach (var rb in _rigidbodies)
        {
            var p = rb.transform.position;
            var v = rb.velocity;

            if (v.magnitude < _minVelocity)
            {
                rb.velocity *= 1.1f;
            }

            if (rb.transform.position.x > xBounds)
            {
                rb.transform.position = new Vector3(xBounds, p.y, p.z);
                rb.velocity = new Vector3(-v.x, v.y, v.z);
            }
            else if (rb.transform.position.x < -xBounds)
            {
                rb.transform.position = new Vector3(-xBounds, p.y, p.z);
                rb.velocity = new Vector3(-v.x, v.y, v.z);
            }

            if (rb.transform.position.y > yBounds)
            {
                rb.transform.position = new Vector3(p.x, yBounds, p.z);
                rb.velocity = new Vector3(v.x, -v.y, v.z);
            }
            else if (rb.transform.position.y < -yBounds)
            {
                rb.transform.position = new Vector3(p.x, -yBounds, p.z);
                rb.velocity = new Vector3(v.x, -v.y, v.z);
            }

            if (rb.transform.position.z > zBounds)
            {
                rb.transform.position = new Vector3(p.x, p.y, zBounds);
                rb.velocity = new Vector3(v.x, v.y, -v.z);
            }
            else if (rb.transform.position.z < -zBounds)
            {
                rb.transform.position = new Vector3(p.x, p.y, -zBounds);
                rb.velocity = new Vector3(v.x, v.y, -v.z);
            }
        }
    }

    private void UpdateScales()
    {
        foreach (var obj in _raymarcher.Objects)
        {
            var dist = Vector3.Distance(obj.transform.position, _origin);
            var scale = Mathf.Clamp((xBounds / 2.0f) / dist, _minScale, _maxScale);

            obj.transform.localScale = _baseScale * scale;
        }
    }
}
