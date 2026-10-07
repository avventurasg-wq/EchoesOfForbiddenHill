using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using UnityEngine.XR.Interaction.Toolkit;

public class VideoButtonHelper : MonoBehaviour
{
    #region Serializables
    [SerializeField]
    Image filler;
    [SerializeField]
    string videoPath;
    #endregion

    #region Properties
    bool isHovered;
    bool isReleased;

    [Header("Testing")]
    [SerializeField]
    bool skipVideoForTesting = false;
    #endregion

    #region Monobehaviours
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        // if (isHovered)
        // {
        //     filler.fillAmount += Time.deltaTime;
        //     if (filler.fillAmount >= 1)
        //     {
        //         TriggerFilledEvent();
        //         isHovered = false;
        //     }
        // }
        // else if (isReleased)
        // {
        //     filler.fillAmount -= Time.deltaTime;
        //     if (filler.fillAmount < 0)
        //     {
        //         filler.fillAmount = 0;
        //         isReleased = false;
        //     }
        // }
    }
    #endregion

    #region Public Methods
    /// <summary>
    /// Trigger event after button is hovered for a duration
    /// </summary>
    public void TriggerVideo()
    {
        Debug.Log($"[VideoButtonHelper] TriggerVideo called for {name}. videoPath={videoPath}");


        if (!skipVideoForTesting && string.IsNullOrEmpty(videoPath))
        {
            Debug.LogWarning($"[VideoButtonHelper] {name} has no videoPath assigned.");
            return;
        }
        if (string.IsNullOrEmpty(videoPath))
        {
            Debug.LogWarning($"[VideoButtonHelper] {name} has no videoPath assigned.");
            return;
        }
        if (VideoManager.Instance == null)
        {
            // Debug.LogWarning($"[VideoButtonHelper] {name} cannot trigger because VideoManager.Instance is null.");
            return;
        }
        if (VideoManager.Instance.IsVideoTriggered)
        {
            Debug.Log($"[VideoButtonHelper] {name} ignored because another video is already triggered.");
            return;
        }
        if (!ArtifactManager.Instance.CanPlay(this))
        {
            Debug.Log($"[VideoButtonHelper] {name} cannot play because it was already watched or blocked.");
            return;
        }

        Debug.Log($"[VideoButtonHelper] Button pressed: {name}");
        ArtifactManager.Instance.MarkWatched(this);
        if (skipVideoForTesting)
        {
            Debug.Log($"[VideoButtonHelper] TEST: {name} marked watched, video skipped");
            return;
        }
        FadeManager.Instance.OnFadeBlackFinished += FadeManager.Instance.HideEnvironment;
        FadeManager.Instance.OnFadeBlackFinished += VideoManager.Instance.StartLoadingVideo;
        VideoManager.Instance.SetVideoPath(videoPath);
        FadeManager.Instance.FadeToBlack(true);
    }



    public void TriggerFilledEvent(InputAction.CallbackContext context)
    {
        //FadeManager.Instance.OnFadeBlackStarted += FadeManager.Instance.HideIndicators;
        FadeManager.Instance.OnFadeBlackFinished += FadeManager.Instance.HideEnvironment;
        FadeManager.Instance.OnFadeBlackFinished += VideoManager.Instance.StartLoadingVideo;
        VideoManager.Instance.SetVideoPath(videoPath);
        FadeManager.Instance.FadeToBlack(true);
    }

    public void OnPressed()
    {
        Debug.Log("OnPressed called");
    }

    #endregion
}
