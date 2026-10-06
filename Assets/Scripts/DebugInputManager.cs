using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.InputSystem;
using UnityEngine.ResourceManagement.AsyncOperations;
using UnityEngine.ResourceManagement.ResourceProviders;
using UnityEngine.SceneManagement;
using UnityEngine.Video;

public class DebugInputManager : MonoBehaviour
{
    [SerializeField]
    List<Transform> samplePositions;

    [SerializeField]
    Transform headset;

    int targetPos;

    [SerializeField]
    ArtifactSnapBehaviour videoButton;

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
    [SerializeField]
    InputActionReference reloadScene;
    [SerializeField]
    InputActionReference teleport0;
    [SerializeField]
    InputActionReference teleport1;
    [SerializeField]
    InputActionReference teleport2;
    [SerializeField]
    InputActionReference teleport3;
    [SerializeField]
    InputActionReference teleport4;
    [SerializeField]
    InputActionReference teleport5;
    [SerializeField]
    InputActionReference teleport6;
    [SerializeField]
    InputActionReference teleport7;

    public AsyncOperationHandle<VideoClip> _VideoHandle { get; private set; }
    AssetReference _VideoToLoad;
    // Start is called before the first frame update
    void Start()
    {
        teleport0.action.performed += MovePlayer0;
        teleport1.action.performed += MovePlayer1;
        teleport2.action.performed += MovePlayer2;
        teleport3.action.performed += MovePlayer3;
        teleport4.action.performed += MovePlayer4;
        teleport5.action.performed += MovePlayer5;
        teleport6.action.performed += MovePlayer6;
        teleport7.action.performed += MovePlayer7;
        reloadScene.action.performed += VideoManager.Instance.ReturnToSite;
        if (videoButton)
        {
            prepareVideo.action.performed += videoButton.PlayVideo;
        }
        //rightPrimaryButtonPressed.action.performed += PlayVideo;
        //rightTriggerPressed.action.performed += LoadVideo;
        //prepareVideo.action.performed += LoadVideo;
        //reloadScene.action.performed += ReloadScene;
    }

    private void OnDestroy()
    {
        teleport0.action.performed -= MovePlayer0;
        teleport1.action.performed -= MovePlayer1;
        teleport2.action.performed -= MovePlayer2;
        teleport3.action.performed -= MovePlayer3;
        teleport4.action.performed -= MovePlayer4;
        teleport5.action.performed -= MovePlayer5;
        teleport6.action.performed -= MovePlayer6;
        teleport7.action.performed -= MovePlayer7;
        reloadScene.action.performed -= VideoManager.Instance.ReturnToSite;
        if (videoButton)
        {
            prepareVideo.action.performed -= videoButton.PlayVideo;
        }
        //if (_VideoHandle.IsValid())
         //{
         //    _VideoHandle.Release();
         //}
         //rightPrimaryButtonPressed.action.performed -= PlayVideo;
         //rightTriggerPressed.action.performed -= LoadVideo;
         //prepareVideo.action.performed -= LoadVideo;
         //reloadScene.action.performed -= ReloadScene;
    }

    private void OnApplicationQuit()
    {
        teleport0.action.performed -= MovePlayer0;
        teleport1.action.performed -= MovePlayer1;
        teleport2.action.performed -= MovePlayer2;
        teleport3.action.performed -= MovePlayer3;
        teleport4.action.performed -= MovePlayer4;
        teleport5.action.performed -= MovePlayer5;
        teleport6.action.performed -= MovePlayer6;
        teleport7.action.performed -= MovePlayer7;
        reloadScene.action.performed -= VideoManager.Instance.ReturnToSite; 
        if (videoButton)
        {
            prepareVideo.action.performed -= videoButton.PlayVideo;
        }
        //if (_VideoHandle.IsValid())
        //{
        //    _VideoHandle.Release();
        //}
        //rightPrimaryButtonPressed.action.performed -= PlayVideo;
        //rightTriggerPressed.action.performed -= LoadVideo;
        //prepareVideo.action.performed -= LoadVideo;
        //reloadScene.action.performed -= ReloadScene;
    }

    void MovePlayer0(InputAction.CallbackContext context)
    {
        headset.position = Vector3.zero;
        headset.rotation = Quaternion.identity;
    }

    void MovePlayer1(InputAction.CallbackContext context)
    {
        targetPos = 1;
        headset.position = samplePositions[targetPos].position;
        headset.rotation = samplePositions[targetPos].rotation;
    }

    void MovePlayer2(InputAction.CallbackContext context)
    {
        targetPos = 2;
        headset.position = samplePositions[targetPos].position;
        headset.rotation = samplePositions[targetPos].rotation;
    }

    void MovePlayer3(InputAction.CallbackContext context)
    {
        targetPos = 3;
        headset.position = samplePositions[targetPos].position;
        headset.rotation = samplePositions[targetPos].rotation;
    }

    void MovePlayer4(InputAction.CallbackContext context)
    {
        targetPos = 4;
        headset.position = samplePositions[targetPos].position;
        headset.rotation = samplePositions[targetPos].rotation;
    }

    void MovePlayer5(InputAction.CallbackContext context)
    {
        targetPos = 5;
        headset.position = samplePositions[targetPos].position;
        headset.rotation = samplePositions[targetPos].rotation;
    }

    void MovePlayer6(InputAction.CallbackContext context)
    {
        targetPos = 6;
        headset.position = samplePositions[targetPos].position;
        headset.rotation = samplePositions[targetPos].rotation;
    }

    void MovePlayer7(InputAction.CallbackContext context)
    {
        targetPos = 0;
        headset.position = samplePositions[targetPos].position;
        headset.rotation = samplePositions[targetPos].rotation;
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
    void ReloadScene(InputAction.CallbackContext context)
    {
        int currentScene = SceneManager.GetActiveScene().buildIndex;
        SceneManager.LoadSceneAsync(currentScene, LoadSceneMode.Single);
        Debug.LogWarning("RELOADING SCENE");
    }

}
