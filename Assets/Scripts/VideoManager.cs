using System;
using System.Collections;
using System.IO;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.InputSystem;
using UnityEngine.ResourceManagement.AsyncOperations;
using UnityEngine.Video;

public class VideoManager : MonoBehaviour
{
    #region Singleton
    public static VideoManager Instance { get; private set; }
    #endregion

    #region Serializables
    [SerializeField]
    GameObject videoMesh;
    [SerializeField]
    VideoPlayer videoPlayer;

    [SerializeField]
    GameObject skipButton;
    #endregion

    #region Properties
    string videoPath;
    bool videoLoading;

    bool isVideoTriggered = false;
    public bool IsVideoTriggered => isVideoTriggered;
    public AsyncOperationHandle<VideoClip> _VideoHandle { get; private set; }
    #endregion

    #region Monobehaviours
    private void Awake()
    {
        if (Instance != null)
        {
            Destroy(this);
            return;
        }
        Instance = this;

        videoPlayer.loopPointReached += ReturnToSite;
    }
    private void OnDestroy()
    {
        if (_VideoHandle.IsValid())
        {
            _VideoHandle.Release();
        }
    }

    private void OnApplicationQuit()
    {
        if (_VideoHandle.IsValid())
        {
            _VideoHandle.Release();
        }
    }
    #endregion

    #region public Methods
    /// <summary>
    /// reset video
    /// </summary>
    public void ResetVideoState()
    {
        isVideoTriggered = false;
    }
    /// <summary>
    /// Play video
    /// </summary>
    void PlayVideo()
    {
        FadeManager.Instance.OnFadeWhiteFinished -= PlayVideo;
        videoPlayer.Play();
        skipButton.SetActive(true);
    }

    /// <summary>
    /// Loads video
    /// </summary>
    public void StartLoadingVideo()
    {
        if (videoLoading)
        {
            return;
        }
        videoLoading = true;
        FadeManager.Instance.OnFadeBlackFinished -= StartLoadingVideo;
        StartCoroutine(LoadVideo());
    }

    /// <summary>
    /// Stops video
    /// </summary>
    public void EndVideo()
    {
        FadeManager.Instance.OnFadeBlackFinished -= EndVideo;
        videoMesh.SetActive(false);
        videoPlayer.Stop();
        skipButton.SetActive(false);
    }

    /// <summary>
    /// Switch to excavation environment
    /// </summary>
    /// <param name="source"></param>
    public void ReturnToSite(VideoPlayer source)
    {
        isVideoTriggered = false;
        FadeManager.Instance.OnFadeBlackFinished += FadeManager.Instance.ShowEnvironment;
        FadeManager.Instance.OnFadeBlackFinished += EndVideo;
        FadeManager.Instance.FadeToBlack(true);
    }

    public void ReturnToSite(InputAction.CallbackContext context)
    {
        isVideoTriggered = false;
        FadeManager.Instance.OnFadeBlackFinished += FadeManager.Instance.ShowEnvironment;
        FadeManager.Instance.OnFadeBlackFinished += EndVideo;
        FadeManager.Instance.FadeToBlack(true);
    }

    /// <summary>
    /// Set video to load
    /// </summary>
    /// <param name="path"></param>
    public void SetVideoPath(string path)
    {
        videoPath = path;
        isVideoTriggered = true;
    }

    /// <summary>
    /// Called by the ✕ poke button to stop the video early
    /// </summary>
    public void SkipVideo()
    {
        if (!videoPlayer.isPlaying)
        {
            return;            // ignore pokes during fades or after it already ended
        }
        skipButton.SetActive(false);
        ReturnToSite(videoPlayer);
    }

    #endregion

    #region Coroutines
    public IEnumerator LoadVideo()
    {
        _VideoHandle = Addressables.LoadAssetAsync<VideoClip>(videoPath);
        yield return _VideoHandle;

        if (_VideoHandle.Status != AsyncOperationStatus.Succeeded)
        {
            Debug.LogError($"Error: {_VideoHandle.Result}");
        }
        else
        {
            Debug.Log(_VideoHandle.Result.originalPath);
            //if (!File.Exists(_VideoHandle.Result.originalPath))
            //{
            //    Debug.Log("File not found");
            //    yield break;
            //}
            videoMesh.SetActive(true);
            videoPlayer.clip = _VideoHandle.Result;
            FadeManager.Instance.FadeToWhite(true);
            FadeManager.Instance.OnFadeWhiteFinished += PlayVideo;
            //yield return new WaitForSeconds(1);
            //player.OpenMedia(_VideoHandle.Result.originalPath);
            //player.Play();
            videoLoading = false;
        }
    }
    #endregion
}
