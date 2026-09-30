using UnityEngine;

[CreateAssetMenu(fileName = "New Artifact Information", menuName = "EOFH/Artifact ScriptableObject")]
public class ArtifactSO : ScriptableObject
{
    public int Index;
    public string ArtifactName;
    public string ArtifactDescription;
    public string VideoPath;

}