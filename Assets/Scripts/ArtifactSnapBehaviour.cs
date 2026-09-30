using System;
using System.Linq;
using Oculus.Interaction;
using Oculus.Interaction.HandGrab;
using TMPro;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.InputSystem;

public class ArtifactSnapBehaviour : MonoBehaviour
{
    #region Serializables
    //[SerializeField]
    //GameObject videoButton;
    [SerializeField]
    ArtifactSO artifactInfo;
    //[SerializeField]
    //int artifactIndex;
    [SerializeField]
    GameObject artifactPanel;
    [SerializeField]
    TextMeshProUGUI title;
    [SerializeField]
    TextMeshProUGUI description;
    [SerializeField]
    bool useSilhouette;
    [SerializeField]
    bool showMesh = false;

    #endregion

    #region Properties
    GameObject indicator;

    string videoPath;

    SnapInteractable snapInteractable;
    #endregion

    #region Monobehaviours
    void Awake()
    {
        if (showMesh)
        {
            transform.GetChild(0).gameObject.SetActive(true);
        }
        else
        {
            transform.GetChild(0).gameObject.SetActive(false);
        }
        if (useSilhouette)
        {
            transform.GetChild(1).gameObject.SetActive(false);
            transform.GetChild(2).gameObject.SetActive(true);
            indicator = transform.GetChild(2).gameObject;
        }
        else
        {
            transform.GetChild(1).gameObject.SetActive(true);
            transform.GetChild(2).gameObject.SetActive(false);
            indicator = transform.GetChild(1).gameObject;
        }

        snapInteractable = GetComponent<SnapInteractable>();

        artifactPanel.SetActive(false);

        title.text = artifactInfo.ArtifactName;
        description.text = artifactInfo.ArtifactDescription;
        videoPath = artifactInfo.VideoPath;
    }
    #endregion

    #region Public Methods
    /// <summary>
    /// Disable grabbable functions and prevents artifact to snap back to origin
    /// </summary>
    public void OnArtifactSnapped()
    {
        snapInteractable.SelectingInteractors.Single().transform.parent.GetComponentInChildren<HandGrabInteractable>().enabled = false;
        snapInteractable.SelectingInteractors.Single().transform.parent.GetComponentInChildren<SnapInteractor>().InjectOptionalTimeOutInteractable(null);
        snapInteractable.SelectingInteractors.Single().transform.parent.GetComponent<Grabbable>().ForceKinematicDisabled = false;
        snapInteractable.SelectingInteractors.Single().transform.parent.GetComponent<Rigidbody>().isKinematic = true;
        //videoButton.SetActive(true);
        //targetInteractor.transform.parent.GetComponentInChildren<HandGrabInteractable>().enabled = false;
        PlayVideo();
    }


    /// <summary>
    /// Fade screen to black, hide environment and load video
    /// </summary>
    public void PlayVideo()
    {
        // Show panel if video path is empty
        if (string.IsNullOrEmpty(videoPath))
        {
            artifactPanel.SetActive(true);
            return;
        }
        //FadeManager.Instance.OnFadeBlackStarted += FadeManager.Instance.HideIndicators;
        FadeManager.Instance.OnFadeBlackFinished += SetPanelActive;
        FadeManager.Instance.OnFadeBlackFinished += FadeManager.Instance.HideEnvironment;
        FadeManager.Instance.OnFadeBlackFinished += VideoManager.Instance.StartLoadingVideo;
        VideoManager.Instance.SetVideoPath(videoPath);
        FadeManager.Instance.FadeToBlack(true);
    }

    /// <summary>
    /// For debugging purpose
    /// </summary>
    /// <param name="context"></param>
    public void PlayVideo(InputAction.CallbackContext context)
    {
        if (string.IsNullOrEmpty(videoPath))
        {
            artifactPanel.SetActive(true);
            return;
        }
        //FadeManager.Instance.OnFadeBlackStarted += FadeManager.Instance.HideIndicators;
        FadeManager.Instance.OnFadeBlackFinished += SetPanelActive;
        FadeManager.Instance.OnFadeBlackFinished += FadeManager.Instance.HideEnvironment;
        FadeManager.Instance.OnFadeBlackFinished += VideoManager.Instance.StartLoadingVideo;
        VideoManager.Instance.SetVideoPath(videoPath);
        FadeManager.Instance.FadeToBlack(true);
    }

    /// <summary>
    /// Sets description panel active after fading to black
    /// </summary>
    public void SetPanelActive()
    {
        FadeManager.Instance.OnFadeBlackFinished -= SetPanelActive;
        artifactPanel.SetActive(true);
    }

    #region Obsolete
    [Obsolete]
    public void SetActiveState(bool state)
    {
        indicator.SetActive(state);
    }

    [Obsolete]
    public bool GetActiveState()
    {
        return indicator.activeSelf;
    }
    #endregion

    #endregion
}
