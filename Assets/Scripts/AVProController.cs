using System.Collections;
using System.Collections.Generic;
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
    MediaPlayer player;

    public AsyncOperationHandle<VideoClip> _VideoHandle { get; private set; }

    private void Awake()
    {
        //Debug.Log(videos[0].originalPath);
        //Debug.Log($"AppData: {PERSISTENT_DATA_FOLDER.ToString()}");
        player = GetComponent<MediaPlayer>();
        PlayVideo();
        //playVideo1.action.performed += PlayVideo;
        //playVideo1.action.performed += PlayVideo2;
    }

    private void OnDestroy()
    {
        //playVideo1.action.performed -= PlayVideo;
        //playVideo1.action.performed -= PlayVideo2;

        if (_VideoHandle.IsValid())
        {
            _VideoHandle.Release();
        }
    }

    private void OnApplicationQuit()
    {
        //playVideo1.action.performed -= PlayVideo;
        //playVideo1.action.performed -= PlayVideo2;

        if (_VideoHandle.IsValid())
        {
            _VideoHandle.Release();
        }
    }

    public void PlayVideo()
    {
        StartCoroutine(LoadVideo());
    }

    public void PlayVideo(InputAction.CallbackContext callbackContext)
    {
        if (_VideoHandle.IsValid())
        {
            _VideoHandle.Release();
        }
        //Addressables.LoadAssetAsync<VideoClip>(_VideoHandle).Completed += LoadVideo;
        //videoAssetReference.LoadAssetAsync<VideoClip>().Completed += LoadVideo;
    }

    public void PlayVideo2(InputAction.CallbackContext callbackContext)
    {
        player.Play();
    }

    IEnumerator LoadVideo()
    {
        //Addressables.LoadAssetAsync<VideoClip>(_VideoHandle).Completed -= LoadVideo;
        //videoAssetReference.LoadAssetAsync<VideoClip>().Completed -= LoadVideo;
        _VideoHandle = Addressables.LoadAssetAsync<VideoClip>(videoAddress[0]);
        yield return _VideoHandle;

        if (_VideoHandle.Status != AsyncOperationStatus.Succeeded)
        {
            Debug.LogError($"Error: {_VideoHandle.Result}");
        }
        else
        {
            Debug.Log(_VideoHandle.Result.originalPath);
            player.OpenMedia(_VideoHandle.Result.originalPath);
            player.Play();
        }

    }
}
