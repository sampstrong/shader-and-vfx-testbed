using UnityEngine;
using UnityEngine.VFX;

public class PortalAudioEvents : MonoBehaviour
{
    [SerializeField] private VisualEffect _effect;
    [SerializeField] private float _threshold = 1.0f;

    private VFXEventAttribute _eventAttribute;

    private float _lastVol = 0.0f;

    private void Start()
    {
        _eventAttribute = _effect.CreateVFXEventAttribute();
    }

    public void GetAudioInput()
    {
        var vol = AudioVisualizeManager.Output_Volume;
        if (vol > _threshold && _lastVol < _threshold)
        {
            TriggerSpawn();
        }
        _lastVol = vol;
    }

    public void TriggerSpawn()
    {
        // _eventAttribute.SetVector3(positionAttribute, player.transform.position);
        
        _effect.SendEvent("OnBeat");
    }
}
