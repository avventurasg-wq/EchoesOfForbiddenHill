using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class DebugSceneSelection : MonoBehaviour
{
    public void LoadSceneByIndex(int index)
    {
        SceneManager.LoadSceneAsync(index, LoadSceneMode.Single);
    }
}
