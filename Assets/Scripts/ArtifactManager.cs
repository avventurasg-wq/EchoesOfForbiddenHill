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

    [Header("Video")]
    [SerializeField]
    List<VideoButtonHelper> videoButtons;

    [SerializeField]
    GameObject ladder;
    [SerializeField]
    bool lockAferWatched = true;

    [SerializeField]
    bool ladderNeedsAllVideos = true;
    #endregion


    #region Properties
    Dictionary<ArtifactSnapBehaviour, ArtifactSO> artifactInfos = new Dictionary<ArtifactSnapBehaviour, ArtifactSO>();
    Dictionary<VideoButtonHelper, bool> videoWatched = new Dictionary<VideoButtonHelper, bool>();

    #endregion

    #region Private Methods
    private void Awake()
    {
        if (Instance != null)
        {
            Destroy(this);
            return;
        }
        Instance = this;
    }

    private void Start()
    {
        foreach (var videoButton in videoButtons)
        {
            videoWatched[videoButton] = false;
        }

        Debug.Log($"[ArtifactManager] Registered {videoWatched.Count} video buttons. Ladder unlock requires all videos: {ladderNeedsAllVideos}");

        if (ladderNeedsAllVideos)
        {
            ladder.SetActive(false);
        }
    }

    private void OnDestroy()
    {
        if (Instance == this)
        {
            Instance = null;
        }
    }
    #endregion

    #region Public Methods

    public bool CanPlay(VideoButtonHelper videoButton)
    {
        if (!lockAferWatched)
        {
            return true;
        }
        if (!videoWatched.ContainsKey(videoButton))
        {
            Debug.LogWarning($"[ArtifactManager] Button not registered in videoWatched: {videoButton?.name}");
            return true;
        }

        bool alreadyWatched = videoWatched[videoButton];
        Debug.Log($"[ArtifactManager] CanPlay check for {videoButton?.name}. Already watched: {alreadyWatched}");
        return !alreadyWatched;
    }

    public void ResetProgress()
    {
        foreach (var key in new List<VideoButtonHelper>(videoWatched.Keys))
        {
            videoWatched[key] = false;
        }

        if (ladder != null)
        {
            ladder.SetActive(false);
        }
        videoWatched.Clear();
        foreach (var button in videoButtons)
        {
            videoWatched[button] = false;
        }
        Debug.Log($"[ArtifactManager] Progress reset. All {videoWatched.Count} videos are now available again");

    }

    public void MarkWatched(VideoButtonHelper button)
    {
        if (button == null)
        {
            Debug.LogWarning("[ArtifactManager] Tried to mark null button as watched.");
            return;
        }

        if (!videoWatched.ContainsKey(button))
        {
            videoWatched[button] = false;
        }

        videoWatched[button] = true;

        int watchedCount = 0;
        foreach (var pair in videoWatched)
        {
            if (pair.Value)
            {
                watchedCount++;
            }
        }

        Debug.Log($"[ArtifactManager] Button pressed: {button.name}. Watched count: {watchedCount}/{videoWatched.Count}");

        foreach (bool watched in videoWatched.Values)
        {
            if (!watched)
            {
                return;
            }
        }

        Debug.Log($"[ArtifactManager] All {videoWatched.Count} video buttons watched. Activating ladder.");
        if (ladder != null)
        {
            ladder.SetActive(true);
        }
        else
        {
            Debug.LogWarning("[ArtifactManager] ladder is null. Drag the ladder object into the ArtifactManager inspector.");
        }
    }
    #endregion
}
