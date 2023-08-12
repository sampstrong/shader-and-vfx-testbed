using UnityEngine;

public class GraphPlotter : MonoBehaviour
{
    [SerializeField] private Transform _pointPrefab;
    [SerializeField, Range(0, 100)] private int _resolution = 10;
    [SerializeField] private FunctionLibrary.FunctionName _functionName;

    private Transform[] _points;
    
    
    private void Awake()
    {
        var step = 2f / _resolution;
        var scale = Vector3.one * step;

        // square resolution for z dimension
        _points = new Transform[_resolution * _resolution];
        for (int i = 0; i < _points.Length; i++)
        {
            var point = _points[i] = Instantiate(
                _pointPrefab, transform, false);
            
            point.localScale = scale;
        }
    }

    private void Update()
    {
        FunctionLibrary.Function func = FunctionLibrary.GetFunction(_functionName);
        
        float time = Time.time;
        float step = 2f / _resolution;
        var v = 0.5f * step - 1f;
        for (int i = 0, x = 0, z = 0; i < _points.Length; i++, x++)
        {
            if (x == _resolution)
            {
                x = 0;
                z++;
                v = (z + 0.5f) * step - 1f;
            }
            var u = (x + 0.5f) * step - 1f;
            _points[i].localPosition = func(u, v, time);
        }
    }

}
