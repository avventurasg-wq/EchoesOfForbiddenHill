using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using UnityEngine.XR.Interaction.Toolkit;

public class VideoButtonHelper : MonoBehaviour
{
    [SerializeField]
    Image filler;
    [SerializeField]
    string videoPath;

    bool isHovered;
    bool isReleased;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (isHovered)
        {
            filler.fillAmount += Time.deltaTime;
            if (filler.fillAmount >= 1)
            {
                TriggerFilledEvent();
                isHovered = false;
            }
        }
        else if (isReleased)
        {
            filler.fillAmount -= Time.deltaTime;
            if (filler.fillAmount < 0)
            {
                filler.fillAmount = 0;
                isReleased = false;
            }
        }
    }

    public void TriggerFilledEvent()
    {
        FadeManager.Instance.OnFadeBlackStarted += FadeManager.Instance.HideIndicators;
        FadeManager.Instance.OnFadeBlackFinished += FadeManager.Instance.HideEnvironment;
        FadeManager.Instance.OnFadeBlackFinished += VideoManager.Instance.StartLoadingVideo;
        VideoManager.Instance.SetVideoPath(videoPath);
        FadeManager.Instance.FadeToBlack(true);
    }

    public void TriggerFilledEvent(InputAction.CallbackContext context)
    {
        FadeManager.Instance.OnFadeBlackStarted += FadeManager.Instance.HideIndicators;
        FadeManager.Instance.OnFadeBlackFinished += FadeManager.Instance.HideEnvironment;
        FadeManager.Instance.OnFadeBlackFinished += VideoManager.Instance.StartLoadingVideo;
        VideoManager.Instance.SetVideoPath(videoPath);
        FadeManager.Instance.FadeToBlack(true);
    }

    public void SetHover(bool active)
    {
        isHovered = active;
        isReleased = !active;
    }
}
