using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class SinAnimation : MonoBehaviour
{
    [SerializeField] private List<GameObject> _cubes;
    [SerializeField] private float _speed = 0.1f;
    float newY = 0f;

    private void Update()
    {
        foreach (var cube in _cubes)
        {
            var currentPos = cube.transform.position;
            
            newY += Time.deltaTime * _speed;
            
            cube.transform.position = new Vector3(currentPos.x, Mathf.Sin(currentPos.x + newY), currentPos.z);
        }
    }
}
