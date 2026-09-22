using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.InputSystem;

public class FadeManager : MonoBehaviour
{
    #region Singleton
    public static FadeManager Instance { get; private set; }
    #endregion

    #region Serializables
    [SerializeField]
    GameObject _environment;

    [SerializeField]
    Material _fadeMaterial;

    [SerializeField]
    float _fadeDuration;

    [Header("Debugging")]
    [SerializeField]
    bool isDebugging = false;

    [SerializeField]
    InputActionReference fadeWhite;

    [SerializeField]
    InputActionReference fadeBlack;
    #endregion

    #region Properties
    Coroutine _fadeCoroutine;
    Coroutine _fadeAudioCoroutine;

    public Action OnFadeBlackStarted;
    public Action OnFadeWhiteStarted;
    public Action OnFadeBlackFinished;
    public Action OnFadeWhiteFinished;

    ArtifactSnapBehaviour[] storages;
    Dictionary<ArtifactSnapBehaviour, bool> activeStorages = new Dictionary<ArtifactSnapBehaviour, bool>();
    #endregion

    #region Monobehaviour
    void Awake()
    {
        if (Instance != null)
        {
            Destroy(this);
            return;
        }
        Instance = this;
        _fadeMaterial.color = Color.clear;
        if (isDebugging)
        {
            fadeBlack.action.performed += FadeToBlack;
            fadeWhite.action.performed += FadeToWhite;
        }
        storages = FindObjectsByType<ArtifactSnapBehaviour>(FindObjectsInactive.Exclude, FindObjectsSortMode.None);
        foreach (ArtifactSnapBehaviour storage in storages)
        {
            activeStorages.Add(storage, true);
        }
    }

    private void OnDestroy()
    {
        _fadeMaterial.color = Color.clear;
        if (isDebugging)
        {
            fadeBlack.action.performed -= FadeToBlack;
            fadeWhite.action.performed -= FadeToWhite;
        }
    }

    private void OnApplicationQuit()
    {
        _fadeMaterial.color = Color.clear;
        if (isDebugging)
        {
            fadeBlack.action.performed -= FadeToBlack;
            fadeWhite.action.performed -= FadeToWhite;
        }
    }
    #endregion

    #region Public Methods

    /// <summary>
    /// Initialize fade to black
    /// </summary>
    /// <param name="force"> Set true to ignore current fade coroutine </param>
    public void FadeToBlack(bool force)
    {
        if (_fadeCoroutine != null)
        {
            if (force)
            {
                StopCoroutine(_fadeCoroutine);
            }
            else
            {
                return;
            }
        }
        _fadeCoroutine = StartCoroutine(FadeBlack());
    }

    /// <summary>
    /// Controls the fade speed/duration
    /// </summary>
    /// <returns></returns>
    IEnumerator FadeBlack()
    {
        OnFadeBlackStarted?.Invoke();
        float elapsed = 0;
        while (elapsed < _fadeDuration)
        {
            _fadeMaterial.color = Color.Lerp(Color.clear, Color.black, elapsed / _fadeDuration);
            elapsed += Time.deltaTime;
            yield return new WaitForEndOfFrame();
        }
        _fadeMaterial.color = Color.black;
        _environment.SetActive(false);
        OnFadeBlackFinished?.Invoke();
        _fadeCoroutine = null;
    }

    /// <summary>
    /// Initialize fade to clear
    /// </summary>
    /// <param name="force"> Set true to ignore current fade coroutine </param>
    public void FadeToWhite(bool force)
    {
        if (_fadeCoroutine != null)
        {
            if (force)
            {
                StopCoroutine(_fadeCoroutine);
            }
            else
            {
                return;
            }
        }
        _fadeCoroutine = StartCoroutine(FadeWhite());
    }


    /// <summary>
    /// Controls the fade speed/duration
    /// </summary>
    /// <returns></returns>
    IEnumerator FadeWhite()
    {
        OnFadeWhiteStarted?.Invoke();
        float elapsed = 0;
        while (elapsed < 1)
        {
            _fadeMaterial.color = Color.Lerp(Color.black, Color.clear, elapsed / _fadeDuration);
            elapsed += Time.deltaTime;
            yield return new WaitForEndOfFrame();
        }
        _fadeMaterial.color = Color.clear;
        OnFadeWhiteFinished?.Invoke();

        _fadeCoroutine = null;
    }

    /// <summary>
    /// Fade out bgm
    /// </summary>
    /// <param name="bgm"> BGM source to fade</param>
    public void FadeOutAudio(AudioSource bgm)
    {
        if (_fadeAudioCoroutine != null)
        {
            return;
        }
        _fadeAudioCoroutine = StartCoroutine(FadingAudio(bgm, 1, 0));
    }

    /// <summary>
    /// Fade in bgm
    /// </summary>
    /// <param name="bgm"> BGM source to fade</param>
    public void FadeInAudio(AudioSource bgm)
    {
        if (_fadeAudioCoroutine != null)
        {
            return;
        }
        _fadeAudioCoroutine = StartCoroutine(FadingAudio(bgm, 0, 1));
    }


    /// <summary>
    /// Controls the fade speed/duration
    /// </summary>
    /// <returns></returns>
    public IEnumerator FadingAudio(AudioSource bgm, float from, float to)
    {
        float elapsed = 0;
        while (elapsed < 1)
        {
            bgm.volume = Mathf.Lerp(from, to, elapsed / _fadeDuration);
            elapsed += Time.deltaTime;
            yield return new WaitForEndOfFrame();
        }
        bgm.volume = to;

        yield return new WaitForEndOfFrame();

        _fadeAudioCoroutine = null;
    }

    public void ShowEnvironment()
    {
        OnFadeBlackFinished -= ShowEnvironment;
        _environment.SetActive(true);
        OnFadeWhiteFinished += RestoreIndicators;
        FadeToWhite(true);
    }

    public void HideEnvironment()
    {
        OnFadeBlackFinished -= HideEnvironment;
        _environment.SetActive(false);
    }
    public void HideIndicators()
    {
        OnFadeBlackStarted -= HideIndicators;
        foreach (ArtifactSnapBehaviour storage in storages)
        {
            activeStorages[storage] = storage.GetActiveState();
            storage.SetActiveState(false);
        }
    }
    public void RestoreIndicators()
    {
        OnFadeWhiteFinished -= RestoreIndicators;
        foreach (ArtifactSnapBehaviour storage in storages)
        {
            storage.SetActiveState(activeStorages[storage]);
        }
    }
    #endregion

    #region Debugging
    public void FadeToBlack(InputAction.CallbackContext callbackContext)
    {
        if (_fadeCoroutine != null)
        {
            return;
        }
        _fadeCoroutine = StartCoroutine(FadeBlack());
    }

    public void FadeToWhite(InputAction.CallbackContext callbackContext)
    {
        if (_fadeCoroutine != null)
        {
            return;
        }
        OnFadeWhiteStarted += ShowEnvironment;
        OnFadeWhiteFinished += RestoreIndicators;
        _fadeCoroutine = StartCoroutine(FadeWhite());
    }
    #endregion
}
