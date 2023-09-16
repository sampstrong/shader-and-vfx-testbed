using UnityEngine;

public class GPUGraph : MonoBehaviour
{
    [SerializeField] private ComputeShader _computeShader;
    [SerializeField] private Material _material;
    [SerializeField] private Mesh _mesh;
    [SerializeField, Range(0, 1000)] private int _resolution = 10;
    [SerializeField] private FunctionLibrary.FunctionName _functionName;
    
    private enum TransitionMode { Cycle, Random }
    [SerializeField] private TransitionMode _transitionMode;
    [SerializeField, Min(0)] private float _functionDuration = 1f, _transitionDuration = 1f;

    private float _duration;
    private bool _transitioning;
    private FunctionLibrary.FunctionName _transitionFunction;

    private static readonly int
        _positionsId = Shader.PropertyToID("_Positions"),
        _resolutionId = Shader.PropertyToID("_Resolution"),
        _stepId = Shader.PropertyToID("_Step"),
        _timeId = Shader.PropertyToID("_Time");

    private struct UvCoord
    {
        public float u;
        public float v;
    }

    private UvCoord[] _uvCoords;

    private ComputeBuffer _positionsBuffer;

    private void OnEnable()
    {
        // each position is a Vector3, so the stride is 3 * 4 bytes per float
        _positionsBuffer = new ComputeBuffer(_resolution * _resolution, 3 * 4);
    }

    private void OnDisable()
    {
        _positionsBuffer.Release();
        _positionsBuffer = null;
    }

    private void Update()
    {
        _duration += Time.deltaTime;
        if (_transitioning)
        {
            if (_duration >= _transitionDuration)
            {
                _duration -= _transitionDuration;
                _transitioning = false;
            }
        }
        else if (_duration >= _functionDuration)
        {
            _duration -= _functionDuration;
            _transitioning = true;
            _transitionFunction = _functionName;
            PickNextFunction();
        }
        
        UpdateFunctionGPU();
    }

    private void PickNextFunction()
    {
        _functionName = _transitionMode == TransitionMode.Cycle
            ? FunctionLibrary.GetNextFunctionName(_functionName)
            : FunctionLibrary.GetRandomFunctionNameOtherThan(_functionName);
    }

    private void UpdateFunctionGPU()
    {
        float step = 2f / _resolution;
        _computeShader.SetInt(_resolutionId, _resolution);
        _computeShader.SetFloat(_stepId, step);
        _computeShader.SetFloat(_timeId, Time.time);
        
        // can use _computeShader.FindKernel() to get the index if multiple kernels
        _computeShader.SetBuffer(0, _positionsId, _positionsBuffer);
        
        // divide resolution by 8 for each dimension because of out fixed 8x8 group size in the compute shader
        int groups = Mathf.CeilToInt(_resolution / 8f);
        _computeShader.Dispatch(0, groups, groups, 1);

        _material.SetBuffer(_positionsId, _positionsBuffer);
        _material.SetFloat(_stepId, step);
        
        var bounds = new Bounds(Vector3.zero, Vector3.one * (2f + 2f / _resolution));
        Graphics.DrawMeshInstancedProcedural(_mesh, 0, _material, bounds, _positionsBuffer.count);
    }

}
