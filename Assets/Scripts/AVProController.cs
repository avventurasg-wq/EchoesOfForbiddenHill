using System.Collections;
using System.Collections.Generic;
using System.IO;
using RenderHeads.Media.AVProVideo;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.InputSystem;
using UnityEngine.ResourceManagement.AsyncOperations;
using UnityEngine.Video;

public class AVProController : MonoBehaviour
{
    //[SerializeField]
    //List<VideoClip> videos;
    [SerializeField]
    List<string> videoAddress;

    [SerializeField]
    InputActionReference playVideo1;

    [SerializeField]
    InputActionReference playVideo2;

    [SerializeField]
    bool enabledInput = false;

    MediaPlayer player;

    public AsyncOperationHandle<VideoClip> _VideoHandle { get; private set; }

    private void Awake()
    {
        //Debug.Log(videos[0].originalPath);
        //Debug.Log($"AppData: {PERSISTENT_DATA_FOLDER.ToString()}");
        player = GetComponent<MediaPlayer>();
        //PlayVideo();

        if (enabledInput)
        {
            playVideo1.action.performed += PlayVideo;
            playVideo2.action.performed += PlayVideo2;
        }
    }
    private void OnDestroy()
    {
        if (enabledInput)
        {
            playVideo1.action.performed -= PlayVideo;
            playVideo2.action.performed -= PlayVideo2;
        }
        if (_VideoHandle.IsValid())
        {
            _VideoHandle.Release();
        }
    }

    private void OnApplicationQuit()
    {

        if (enabledInput)
        {
            playVideo1.action.performed -= PlayVideo;
            playVideo2.action.performed -= PlayVideo2;
        }
        if (_VideoHandle.IsValid())
        {
            _VideoHandle.Release();
        }
    }

    public void PlayVideo()
    {
        StartCoroutine(LoadVideo(0));
    }

    public void PlayVideo(InputAction.CallbackContext callbackContext)
    {
        Debug.Log("Button Pressed");
        //if (_VideoHandle.IsValid())
        //{
        //    _VideoHandle.Release();
        //}
        StartCoroutine(LoadVideo(0));
        //Addressables.LoadAssetAsync<VideoClip>(_VideoHandle).Completed += LoadVideo;
        //videoAssetReference.LoadAssetAsync<VideoClip>().Completed += LoadVideo;
    }

    public void PlayVideo2(InputAction.CallbackContext callbackContext)
    {
        StartCoroutine(LoadVideo(1));

    }

    IEnumerator LoadVideo(int index)
    {
        Debug.Log($"Playing Video {index}");
        //if (_VideoHandle.IsValid())
        //{
        //    _VideoHandle.Release();
        //}
        //Addressables.LoadAssetAsync<VideoClip>(_VideoHandle).Completed -= LoadVideo;
        //videoAssetReference.LoadAssetAsync<VideoClip>().Completed -= LoadVideo;
        _VideoHandle = Addressables.LoadAssetAsync<VideoClip>(videoAddress[index]);
        yield return _VideoHandle;

        if (_VideoHandle.Status != AsyncOperationStatus.Succeeded)
        {
            Debug.LogError($"Error: {_VideoHandle.Result}");
        }
        else
        {
            Debug.Log(_VideoHandle.Result.originalPath);
            if (File.Exists(_VideoHandle.Result.originalPath))
            {
                Debug.Log("File found");
            }
            //yield return new WaitForSeconds(1);
            //player.OpenMedia(_VideoHandle.Result.originalPath);
            //player.Play();
        }

    }
}
