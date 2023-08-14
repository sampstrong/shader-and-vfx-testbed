using UnityEngine;

public class CameraSync : MonoBehaviour
{
    private Camera _camera;
    public Camera cameraToSync;

    private void Awake()
    {
        _camera = GetComponent<Camera>();
    }

    private void Update()
    {
        _camera.fieldOfView = cameraToSync.fieldOfView;
        _camera.transform.position = cameraToSync.transform.position;
        _camera.transform.rotation = cameraToSync.transform.rotation;
    }
}
