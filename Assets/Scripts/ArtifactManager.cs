using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ArtifactManager : MonoBehaviour
{
    #region Singleton
    public static ArtifactManager Instance { get; private set; }
    #endregion

    #region Serializables
    [SerializeField]
    List<ArtifactSO> artifactSOs;
    [SerializeField]
    List<ArtifactSnapBehaviour> artifactStorages;

    Dictionary<ArtifactSnapBehaviour, ArtifactSO> artifactInfos = new Dictionary<ArtifactSnapBehaviour, ArtifactSO>();
    #endregion

    private void Awake()
    {
        if (Instance != null)
        {
            Destroy(this);
            return;
        }
        Instance = this;
    }
}
