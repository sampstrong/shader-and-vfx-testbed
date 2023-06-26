using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RandomRotator : MonoBehaviour
{
    [SerializeField] private float _speed = 20f;
    
    void Update()
    {
        ContinuouslyRotate();
    }
    
    private void ContinuouslyRotate()
    {
        transform.Rotate(Vector3.up, _speed * Time.deltaTime);
        transform.Rotate(Vector3.right, _speed / 3 * Time.deltaTime);
    }
}
