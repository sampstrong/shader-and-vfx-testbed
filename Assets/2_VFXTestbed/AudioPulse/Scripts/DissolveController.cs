using UnityEngine;
using UnityEngine.VFX;

public class DissolveController : MonoBehaviour
{
    [SerializeField] private float _amount;
    [SerializeField] private VisualEffect _effect;
    [SerializeField] private Material _material;

    private void Update()
    {
        _amount = Mathf.Sin(Time.unscaledTime) * 1.5f;
        SetEffectAmount(_amount);
        SetMaterialAmount(_amount);
    }

    private void SetEffectAmount(float amount)
    {
        _effect.SetFloat("Amount", amount);
    }

    private void SetMaterialAmount(float amount)
    {
        float newAmount = ((amount + 0.5f) * 10f) + 25f;
        
        _material.SetFloat("_SwapThreshold", newAmount);
    }
}
