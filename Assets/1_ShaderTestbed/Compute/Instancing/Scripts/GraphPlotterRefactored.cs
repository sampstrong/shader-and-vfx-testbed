using UnityEngine;

public class GraphPlotterRefactored : MonoBehaviour
{
    [SerializeField] private Transform _pointPrefab;
    [SerializeField, Range(0, 100)] private int _resolution = 10;
    [SerializeField] private FunctionLibrary.FunctionName _functionName;

    private Transform[] _points;

    private struct UvCoord
    {
        public float u;
        public float v;
    }

    private UvCoord[] _uvCoords;
    
    private void Awake()
    {
        _points = new Transform[(int)Mathf.Pow(_resolution, 2f)];
        _uvCoords = new UvCoord[_points.Length];
        
        SetUpUvs();
    }

    private void Update()
    {
        FunctionLibrary.Function func = FunctionLibrary.GetFunction(_functionName);
        
        float time = Time.time;
        for (int i = 0; i < _points.Length; i++)
        {
            var coord = _uvCoords[i];
            _points[i].localPosition = func(coord.u, coord.v, time);
        }
    }
    
    private void SetUpUvs()
    {
        var step = 2f / _resolution;
        var scale = Vector3.one * step;

        for (int i = 0, x = 0, z = 0; i < _points.Length; i++, x++)
        {
            if (x == _resolution)
            {
                x = 0;
                z++;
            }

            var point = _points[i] = Instantiate(
                _pointPrefab, transform, false);

            UvCoord coord;
            coord.u = (x + 0.5f) * step - 1f;
            coord.v = (z + 0.5f) * step - 1f;
            _uvCoords[i] = coord;

            point.localScale = scale;
        }
    }

}
