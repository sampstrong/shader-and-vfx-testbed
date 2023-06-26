using System.Collections;
using UnityEngine;

public class RotationShifter : MonoBehaviour
{
    private enum RotDirection
    {
        xPos = 0,
        xNeg = 1,
        yPos = 2,
        yNeg = 3,
        zPos = 4,
        zNeg = 5
    }

    private RotDirection _rotDirection;

    [SerializeField] private float _rotTimer = 0f;
    [SerializeField] private float _rotInterval = 2f;
    [SerializeField] private float _rotDuration = 0.5f;
        
    void Update()
    {
        
        
        _rotTimer += Time.deltaTime;
        if (_rotTimer >= _rotInterval)
        {
            var newRot = GetRandomRotation();
            StartCoroutine(LerpToNewRotation(transform.rotation, newRot));
            _rotTimer = 0f;
        }
    }

    private Quaternion GetRandomRotation()
    {
        int directionIndex = Random.Range(0, 6);

        _rotDirection = (RotDirection)directionIndex;

        Quaternion currentRot = transform.rotation;
        Quaternion newRot = Quaternion.identity;

        switch (_rotDirection)
        {
            case RotDirection.xNeg:
                newRot = currentRot * Quaternion.Euler(-90, 0, 0);
                break;
            case RotDirection.xPos:
                newRot = currentRot * Quaternion.Euler(90, 0, 0);
                break;
            case RotDirection.yNeg:
                newRot = currentRot * Quaternion.Euler(0, -90, 0);
                break;
            case RotDirection.yPos:
                newRot = currentRot * Quaternion.Euler(0, 90, 0);
                break;
            case RotDirection.zNeg:
                newRot = currentRot * Quaternion.Euler(0, 0, -90);
                break;
            case RotDirection.zPos:
                newRot = currentRot * Quaternion.Euler(0, 0, 90);
                break;
        }

        return newRot;
    }

    private IEnumerator LerpToNewRotation(Quaternion startRot, Quaternion endRot)
    {
        for (float t = 0; t < _rotDuration; t += Time.deltaTime)
        {
            var rot = Quaternion.Slerp(startRot, endRot, t / _rotDuration);
            transform.rotation = rot;

            yield return null;
        }

        transform.rotation = endRot;
    }
}
