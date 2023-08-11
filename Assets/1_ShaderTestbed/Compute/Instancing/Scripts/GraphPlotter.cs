using UnityEngine;

public class GraphPlotter : MonoBehaviour
{
    [SerializeField] private Transform _pointPrefab;
    [SerializeField, Range(0, 100)] private int _resolution = 10;
    
    
    void Awake()
    {
        var step = 2f / _resolution;
        var position = Vector3.zero;
        var scale = Vector3.one * step;
        for (int i = 0; i < _resolution; i++)
        {
            var point = Instantiate(_pointPrefab, transform, false);
            
            // sets positions between -1 and 1
            position.x = (i + 0.5f) * step - 1f;
            
            // functions
            // position.y = position.x;
            position.y = Mathf.Pow(position.x, 2f);

            point.localPosition = position;
            point.localScale = scale;
        }
    }

}
