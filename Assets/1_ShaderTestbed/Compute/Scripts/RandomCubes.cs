using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.Experimental;
using UnityEngine;
using Random = UnityEngine.Random;

public class RandomCubes : MonoBehaviour
{
    [SerializeField] private GameObject _cubePrefab;
    [SerializeField] private Shader _shader;
    [SerializeField] private int _numX = 50;
    [SerializeField] private int _numY = 50;
    [SerializeField] private int _repetitions;
    [SerializeField] private ComputeShader _computeShader;

    private List<GameObject> _objects = new List<GameObject>();

    public struct Cube
    {
        public Vector3 position;
        public Color color;
    }

    private Cube[] data;
    
    void Start()
    {
        CreateCubes();
    }

    private void CreateCubes()
    {
        data = new Cube[_numX * _numY];
        
        for (int x = 0; x < _numX; x++)
        {
            for (int y = 0; y < _numY; y++)
            {
                var z = Random.Range(-0.1f, 0.1f);
                var cube = Instantiate(_cubePrefab, new Vector3(x, y, z), Quaternion.identity);
                _objects.Add(cube);
                
                var color = Random.ColorHSV();
                var mat = new Material(_shader);
                var rend = cube.GetComponent<Renderer>();
                rend.material = mat;
                rend.material.SetColor("_Color", color);

                Cube cubeData = new Cube();
                cubeData.position = cube.transform.position;
                cubeData.color = color;
                data[x * _numX + y] = cubeData;
            }
        }
    }

    public void OnRandomizeGPU()
    {
        // get the stride of the buffer in bytes
        int colorSize = sizeof(float) * 4;
        int vector3size = sizeof(float) * 3;
        var totalSize = colorSize + vector3size;
        
        ComputeBuffer cubesBuffer = new ComputeBuffer(data.Length, totalSize);
        cubesBuffer.SetData(data);

        _computeShader.SetBuffer(0, "cubes", cubesBuffer);
        _computeShader.SetFloat("resolution", data.Length);
        _computeShader.Dispatch(0, data.Length / 10, 1, 1);
        
        cubesBuffer.GetData(data);

        for (int i = 0; i < _objects.Count; i++)
        {
            GameObject obj = _objects[i];
            Cube cube = data[i];
            obj.transform.position = cube.position;
            obj.GetComponent<MeshRenderer>().material.SetColor("_Color", cube.color);
        }
        
        cubesBuffer.Dispose();
    }

    public void OnRandomizeCPU()
    {
        for (int i = 0; i < _repetitions; i++)
        {
            for (int c = 0; c < _objects.Count; c++)
            {
                GameObject obj = _objects[c];
                obj.transform.position = new Vector3(obj.transform.position.x, obj.transform.position.y,
                    Random.Range(-0.1f, 0.1f));
                obj.GetComponent<MeshRenderer>().material.SetColor("_Color", Random.ColorHSV());
                Debug.Log(obj.GetComponent<MeshRenderer>().material);
            }
        }
    }
}
