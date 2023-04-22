using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BeatListenerC : MonoBehaviour
{
    private Transform targetTransform;
    private Vector3 startTransform;

    private void Awake() //I guess I should put most my refrence grabbing on awake not start
    {
        targetTransform = gameObject.transform; //weird, after rebooting project I had to change this from start to awake
        startTransform = new Vector3(targetTransform.localScale.x, targetTransform.localScale.y, targetTransform.localScale.z);
    }

    public void ListenToVolumeChange()
    {
        if (!gameObject.activeSelf)
            return;

        targetTransform.localScale = new Vector3(
            startTransform.x * (AudioVisualizeManager.Output_Volume + 1),
            startTransform.y ,
            startTransform.z * (AudioVisualizeManager.Output_Volume + 1));
    }
}
