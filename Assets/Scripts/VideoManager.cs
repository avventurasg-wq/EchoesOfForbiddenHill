using System;
using System.Collections;
using System.IO;
using RenderHeads.Media.AVProVideo;
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
    GameObject avProVideoMesh;
    [SerializeField]
    GameObject hisVideoMesh;
    [SerializeField]
    VideoPlayer videoPlayer;
    [SerializeField]
    MediaPlayer avProPlayer;
    [SerializeField]
    HISPlayerVRController hisPlayer;

    [SerializeField]
    GameObject skipButton;
    #endregion

    #region Properties
    string videoPath;
    bool videoLoading;
    MediaReference mediaReference;
    int videoIndex;


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
    /// Loads video
    /// </summary>
    public void StartLoadingAVProVideo()
    {
        FadeManager.Instance.OnFadeBlackFinished -= StartLoadingAVProVideo;
        if (videoLoading)
        {
            return;
        }
        videoLoading = true;
        //StartCoroutine(LoadVideo());
        FadeManager.Instance.FadeToWhite(true);
        skipButton.SetActive(true);
        avProVideoMesh.SetActive(true);
        avProPlayer.OpenMedia(mediaReference, true);
        videoLoading = false;
    }


    /// <summary>
    /// Loads video
    /// </summary>
    public void StartLoadingHISVideo()
    {
        FadeManager.Instance.OnFadeBlackFinished -= StartLoadingHISVideo;
        if (videoLoading)
        {
            return;
        }
        videoLoading = true;
        //StartCoroutine(LoadVideo());
        FadeManager.Instance.FadeToWhite(true);
        skipButton.SetActive(true);
        hisVideoMesh.SetActive(true);
        hisPlayer.OnSelectPlayback(videoIndex);
        videoLoading = false;
    }

    /// <summary>
    /// Stops video
    /// </summary>
    public void EndVideo()
    {
        FadeManager.Instance.OnFadeBlackFinished -= EndVideo;
        videoMesh.SetActive(false);
        videoPlayer.Stop();
        avProVideoMesh.SetActive(false);
        avProPlayer.Stop();
        hisVideoMesh.SetActive(false);
        hisPlayer.OnStop();
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
    /// Set AVPro video to load
    /// </summary>
    /// <param name="path"></param>
    public void SetAVProVideo(MediaReference _mediaReference)
    {
        mediaReference = _mediaReference;
        isVideoTriggered = true;
    }

    /// <summary>
    /// Set HISPlayer video to load
    /// </summary>
    /// <param name="path"></param>
    public void SetHISVideo(int index)
    {
        videoIndex = index;
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
            //return;            // ignore pokes during fades or after it already ended
        }
        else if (avProVideoMesh.activeSelf || hisVideoMesh.activeSelf)
        {
            ReturnToSite();
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
    #endregion
}
