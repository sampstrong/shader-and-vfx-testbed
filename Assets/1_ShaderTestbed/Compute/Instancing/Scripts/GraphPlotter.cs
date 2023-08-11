using UnityEngine;

public class GraphPlotter : MonoBehaviour
{
    [SerializeField] private Transform _pointPrefab;
    [SerializeField, Range(0, 100)] private int _resolution = 10;

    private Transform[] _points;
    
    
    private void Awake()
    {
        var step = 2f / _resolution;
        var position = Vector3.zero;
        var scale = Vector3.one * step;

        _points = new Transform[_resolution];
        for (int i = 0; i < _resolution; i++)
        {
            var point = _points[i] = Instantiate(_pointPrefab, transform, false);

            // sets positions between -1 and 1
            position.x = (i + 0.5f) * step - 1f;
            
            // functions - to be set in update instead
            // position.y = position.x;
            // position.y = Mathf.Pow(position.x, 3f);

            point.localPosition = position;
            point.localScale = scale;
        }
    }

    private void Update()
    {
        float time = Time.time;
        for (int i = 0; i < _points.Length; i++)
        {
            var point = _points[i];
            var position = point.localPosition;
            position.y = Mathf.Sin(Mathf.PI * (position.x + time));
            point.position = position;
        }
    }

}
