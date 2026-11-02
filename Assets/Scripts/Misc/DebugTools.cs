using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DebugTools : MonoBehaviour
{
    public void RotateExperience(bool right)
    {
        GameFlowManager.Instance.RotateExperience(right);
    }
}
