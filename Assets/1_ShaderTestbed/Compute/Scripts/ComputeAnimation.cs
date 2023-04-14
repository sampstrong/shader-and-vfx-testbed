using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class ComputeAnimation : MonoBehaviour
{
    [Header("Camera")] 
    [SerializeField] private Camera _camera;
    
    [Header("Shaders")]
    [SerializeField] private ComputeShader _computeShader;
    [SerializeField] private Shader _shader;
    
    [Header("Particles")]
    [SerializeField] private ComputeParticle _particlePrefab;
    [SerializeField] private int _count;
    [SerializeField] private float _yRange;
    [SerializeField] private float _innerRadius;
    [SerializeField] private float _outerRadius;
    
    
    private List<ComputeParticle> _objects = new List<ComputeParticle>();

    private ComputeBuffer _computeBuffer;
    
    struct Particle
    {
        public Vector3 position;
        public Vector3 direction;
        public Color color;
        public float angle;
        public float radius;
        public float yOffset;
    }

    private Particle[] _bufferData;
    
    void Start()
    {
        CreateParticles();
        CreateComputeBuffer();
    }

    private void CreateParticles()
    {
        _bufferData = new Particle[_count];
        
        for (int i = 0; i < _count; i++)
        {
            Vector3 direction = new Vector3(90, 0, 0);
            float angle = Random.Range(1f, 360f);
            float radius = Random.Range(_innerRadius, _outerRadius);
            float x = Mathf.Sin(angle) * radius;
            float z = Mathf.Cos(angle) * radius;
            float y = Random.Range(-_yRange, _yRange);
            var particle = Instantiate(
                _particlePrefab, 
                new Vector3(x, y, z), 
                Quaternion.LookRotation(direction)
            );
            _objects.Add(particle);

            x = x * 0.5f + 0.5f;
            y = y * 0.5f + 0.5f;
            z = z * 0.5f + 0.5f;

            var color = new Color(x, y, z);
            var rend = particle.renderer;
            rend.material = new Material(_shader);
            rend.material.SetColor("_Color", color);

            Particle particleData = new Particle();
            particleData.position = particle.transform.position;
            particleData.color = color;
            particleData.angle = angle;
            particleData.radius = radius;
            particleData.yOffset = particle.transform.position.y;
            _bufferData[i] = particleData;
        }
    }

    private void CreateComputeBuffer()
    {
        int positionSize = sizeof(float) * 3;
        int directionSize = sizeof(float) * 3;
        int colorSize = sizeof(float) * 4;
        int angleSize = sizeof(float);
        int radiusSize = sizeof(float);
        int yOffsetSize = sizeof(float);
        int totalSize = positionSize + directionSize + colorSize + angleSize + radiusSize + yOffsetSize;
        _computeBuffer = new ComputeBuffer(_bufferData.Length, totalSize);
        _computeBuffer.SetData(_bufferData);
        _computeShader.SetBuffer(0, "particleBuffer", _computeBuffer);
        _computeShader.SetFloat("count", _objects.Count);
    }

    void Update()
    {
        _computeShader.SetFloat("deltaTime", Time.deltaTime);
        var camPos = _camera.transform.position;
        Vector4 camPosV4 = new Vector4(camPos.x, camPos.y, camPos.z, 1);
        _computeShader.SetVector("camPos", camPosV4);
        _computeShader.Dispatch(0, _bufferData.Length/ 10, 1, 1);
        
        _computeBuffer.GetData(_bufferData);

        for (int i = 0; i < _objects.Count; i++)
        {
            var obj = _objects[i];
            Particle particle = _bufferData[i];
            Color color = new Color(
                _bufferData[i].color.r, 
                _bufferData[i].color.g, 
                _bufferData[i].color.b
            );
            obj.transform.position = particle.position;
            obj.transform.rotation = Quaternion.LookRotation(_bufferData[i].direction);
            obj.renderer.material.SetColor("_Color", color);
        }
    }
    
    
}
