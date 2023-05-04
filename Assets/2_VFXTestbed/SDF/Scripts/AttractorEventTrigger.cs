using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class AttractorEventTrigger : MonoBehaviour
{
    [SerializeField] private VisualEffect _effect;



    private void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            TriggerSpawn();
        }
    }
    
    public void TriggerSpawn()
    {
        _effect.SendEvent("OnClick");
    }
}
