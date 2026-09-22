using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Oculus.Interaction;
using Oculus.Interaction.HandGrab;
using UnityEngine;
using UnityEngine.InputSystem;

public class ArtifactSnapBehaviour : MonoBehaviour
{
    [SerializeField]
    GameObject videoButton;
    [SerializeField]
    bool useSilhouette;
    [SerializeField]
    bool showMesh = false;

    [SerializeField]
    string videoPath;

    GameObject indicator;

    SnapInteractable snapInteractable;

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
    }

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

    public void PlayVideo()
    {
        FadeManager.Instance.OnFadeBlackStarted += FadeManager.Instance.HideIndicators;
        FadeManager.Instance.OnFadeBlackFinished += FadeManager.Instance.HideEnvironment;
        FadeManager.Instance.OnFadeBlackFinished += VideoManager.Instance.StartLoadingVideo;
        VideoManager.Instance.SetVideoPath(videoPath);
        FadeManager.Instance.FadeToBlack(true);
    }

    public void PlayVideo(InputAction.CallbackContext context)
    {
        FadeManager.Instance.OnFadeBlackStarted += FadeManager.Instance.HideIndicators;
        FadeManager.Instance.OnFadeBlackFinished += FadeManager.Instance.HideEnvironment;
        FadeManager.Instance.OnFadeBlackFinished += VideoManager.Instance.StartLoadingVideo;
        VideoManager.Instance.SetVideoPath(videoPath);
        FadeManager.Instance.FadeToBlack(true);
    }

    public void SetActiveState(bool state)
    {
        indicator.SetActive(state);
    }

    public bool GetActiveState()
    {
        return indicator.activeSelf;
    }
}
