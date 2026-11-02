using System;
using System.Collections;
using System.Collections.Generic;
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
    [SerializeField]
    bool enableSkip;
    #endregion

    #region Properties
    string videoPath;
    VideoClip videoClip;
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
        //FadeManager.Instance.OnFadeWhiteFinished -= PlayVideo;
        videoPlayer.Play();
        if (enableSkip)
        {
            skipButton.SetActive(true);
        }
    }

    /// <summary>
    /// Loads video
    /// </summary>
    public void StartLoadingVideo()
    {
        //FadeManager.Instance.OnFadeBlackFinished -= StartLoadingVideo;
        if (videoLoading)
        {
            return;
        }
        videoLoading = true;
        StartCoroutine(LoadVideo());
    }

    /// <summary>
    /// Loads data video
    /// </summary>
    public void StartLoadingDataVideo()
    {
        FadeManager.Instance.OnFadeBlackFinished -= StartLoadingDataVideo;
        if (videoLoading)
        {
            return;
        }
        videoLoading = true;
        // 1. Construct the path safely using Path.Combine
        string fullPath = Path.Combine(Application.persistentDataPath, $"{videoPath}.mp4");

        // 2. Verify the file actually exists on the device storage
        if (!File.Exists(fullPath))
        {
            Debug.LogError($"[VideoPlayer] Video file not found at: {fullPath}");
            ReturnToSite();
            return;
        }

        Debug.Log($"[VideoPlayer] Loading video from: {fullPath}");

        // 3. Configure VideoPlayer to receive a file URL
        videoPlayer.source = VideoSource.Url;
        videoPlayer.url = fullPath;

        // 4. Hook into the preparation event and prepare asynchronously
        videoPlayer.prepareCompleted += OnVideoPrepared;
        videoPlayer.Prepare();
    }
    private void OnVideoPrepared(VideoPlayer source)
    {
        // Unsubscribe to avoid memory leaks
        videoPlayer.prepareCompleted -= OnVideoPrepared;

        videoMesh.SetActive(true);
        Debug.Log("[VideoPlayer] Video preparation complete. Starting playback.");
        videoPlayer.Play();
        FadeManager.Instance.FadeToWhite(true);
        if (enableSkip)
        {
            skipButton.SetActive(true);
        }
        videoLoading = false;
    }
    /// <summary>
    /// Loads video
    /// </summary>
    public void StartLoadingAddressableVideo()
    {
        FadeManager.Instance.OnFadeBlackFinished -= StartLoadingAddressableVideo;
        if (videoLoading)
        {
            return;
        }
        videoLoading = true;
        StartCoroutine(LoadAddressableVideo());
        //FadeManager.Instance.OnFadeWhiteFinished += PlayVideo;
        //videoLoading = false;
    }
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
    public void ReturnToSite()
    {
        isVideoTriggered = false;
        FadeManager.Instance.OnFadeBlackFinished += FadeManager.Instance.ShowEnvironment;
        FadeManager.Instance.OnFadeBlackFinished += EndVideo;
        FadeManager.Instance.FadeToBlack(true);
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
    /// Set video to load
    /// </summary>
    /// <param name="path"></param>
    public void SetVideoClip(VideoClip clip)
    {
        videoClip = clip;
        //videoPlayer.clip = clip;
        isVideoTriggered = true;
    }
    /// <summary>
    /// Called by the ✕ poke button to stop the video early
    /// </summary>
    public void SkipVideo()
    {
        if (videoPlayer.isPlaying)
        {
            ReturnToSite(videoPlayer);
            return;            // ignore pokes during fades or after it already ended
        }
        skipButton.SetActive(false);
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
            PlayVideo();
            FadeManager.Instance.FadeToWhite(true);
            //FadeManager.Instance.OnFadeWhiteFinished += PlayVideo;
            //yield return new WaitForSeconds(1);
            //player.OpenMedia(_VideoHandle.Result.originalPath);
            //player.Play();
            videoLoading = false;
        }
    }
    public IEnumerator LoadAddressableVideo()
    {
        _VideoHandle = Addressables.LoadAssetAsync<VideoClip>(videoPath);
        yield return _VideoHandle;

        if (_VideoHandle.Status != AsyncOperationStatus.Succeeded)
        {
            Debug.LogError($"Error: {_VideoHandle.Result}");
        }
        else
        {
            videoMesh.SetActive(true);
            videoPlayer.clip = _VideoHandle.Result;
            videoPlayer.Play();
            yield return new WaitUntil(() => videoPlayer.isPlaying);
            FadeManager.Instance.FadeToWhite(true);
            videoLoading = false;
        }
    }
    #endregion
}
