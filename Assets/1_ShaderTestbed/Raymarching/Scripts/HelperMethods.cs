using UnityEngine;

public class HelperMethods
{
    public static Vector3 GetRandomVec3()
    {
        var x = Random.value;
        var y = Random.value;
        var z = Random.value;

        return new Vector3(x, y, z);
    }
}
