using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.InputSystem;
using UnityEngine.ResourceManagement.AsyncOperations;
using UnityEngine.ResourceManagement.ResourceProviders;
using UnityEngine.Video;

public class DebugInputManager : MonoBehaviour
{
    [SerializeField]
    VideoPlayer _videoPlayer;

    [SerializeField]
    string _videoAddress;

    [Header("Input Actions")]
    [SerializeField]
    InputActionReference rightPrimaryButtonPressed;
    [SerializeField]
    InputActionReference rightTriggerPressed;
    [SerializeField]
    InputActionReference prepareVideo;

    public AsyncOperationHandle<VideoClip> _VideoHandle { get; private set; }
    AssetReference _VideoToLoad;
    // Start is called before the first frame update
    void Start()
    {
        rightPrimaryButtonPressed.action.performed += PlayVideo;
        rightTriggerPressed.action.performed += LoadVideo;
        prepareVideo.action.performed += LoadVideo;
    }

    private void OnDestroy()
    {
        if (_VideoHandle.IsValid())
        {
            _VideoHandle.Release();
        }
        rightPrimaryButtonPressed.action.performed -= PlayVideo;
        rightTriggerPressed.action.performed -= LoadVideo;
        prepareVideo.action.performed -= LoadVideo;
    }

    private void OnApplicationQuit()
    {
        if (_VideoHandle.IsValid())
        {
            _VideoHandle.Release();
        }
        rightPrimaryButtonPressed.action.performed -= PlayVideo;
        rightTriggerPressed.action.performed -= LoadVideo;
        prepareVideo.action.performed -= LoadVideo;
    }

    void PlayVideo(InputAction.CallbackContext context)
    {
        Debug.Log("Play Video");
        if (_videoPlayer.clip != null)
        {
            _videoPlayer.Play();
        }
    }

    void PlayVideo(VideoPlayer source)
    {
        Debug.Log("Play Video");
        if (_videoPlayer.clip != null)
        {
            _videoPlayer.Play();
        }
    }

    void LoadVideo(InputAction.CallbackContext context)
    {
        Debug.Log("Load Video");
        StartCoroutine(LoadVideoAddressable());
    }

    IEnumerator LoadVideoAddressable()
    {
        _VideoHandle = Addressables.LoadAssetAsync<VideoClip>(_videoAddress);
        yield return _VideoHandle;

        if (_VideoHandle.Status == AsyncOperationStatus.Succeeded)
        {
            VideoClip clip = _VideoHandle.Result;
            _videoPlayer.clip = clip;
            _videoPlayer.Prepare();
            _videoPlayer.prepareCompleted += PlayVideo;
        }
    }
}
