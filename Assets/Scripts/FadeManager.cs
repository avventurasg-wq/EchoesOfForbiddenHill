using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;



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
    Volume _fadeVolume;

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
    private ColorParameter _colorParameter = null;

    Coroutine _fadeCoroutine;
    Coroutine _fadeAudioCoroutine;

    public Action OnFadeBlackStarted;
    public Action OnFadeWhiteStarted;
    public Action OnFadeBlackFinished;
    public Action OnFadeWhiteFinished;

    ArtifactSnapBehaviour[] storages;
    Dictionary<ArtifactSnapBehaviour, bool> activeStorages = new Dictionary<ArtifactSnapBehaviour, bool>();

    public GameObject[] hiddenEnvironment;
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

        if (_fadeVolume != null)
        {
            _fadeVolume.weight = 0f;
        }
        //_fadeMaterial.color = Color.clear;
        //if (_fadeVolume.profile.TryGet(out ColorAdjustments _colorAdjustments))
        //{
        //    _colorParameter = _colorAdjustments.colorFilter;
        //    _colorParameter.value = Color.white;
        //}
        //else
        //{
        //    Debug.LogError($"{gameObject.name}: No ColorParameter found for this volume");
        //}

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
        _fadeVolume.weight = 0f;
        //_colorParameter.value = Color.white;
        //_fadeMaterial.color = Color.clear;
        if (isDebugging)
        {
            fadeBlack.action.performed -= FadeToBlack;
            fadeWhite.action.performed -= FadeToWhite;
        }
    }

    private void OnApplicationQuit()
    {
        _fadeVolume.weight = 0f;
        //_colorParameter.value = Color.white;
        //_fadeMaterial.color = Color.clear;
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
            _fadeVolume.weight = Mathf.Lerp(0f, 1f, elapsed / _fadeDuration);
            //_colorParameter.Interp(Color.clear, Color.black, elapsed / _fadeDuration);

            //_fadMaterial.color = Color.Lerp(Color.clear, Color.black, elapsed / _fadeDuration);
            elapsed += Time.deltaTime;
            yield return new WaitForEndOfFrame();
        }
        _fadeVolume.weight = 1f;
        //_colorParameter.value = Color.black;
        //_fadeMaterial.color = Color.black;
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
            _fadeVolume.weight = Mathf.Lerp(1f, 0f, elapsed / _fadeDuration);
            //_colorParameter.Interp(Color.black, Color.clear, elapsed / _fadeDuration);
            //_fadeMaterial.color = Color.Lerp(Color.black, Color.clear, elapsed / _fadeDuration);
            elapsed += Time.deltaTime;
            yield return new WaitForEndOfFrame();
        }
        _fadeVolume.weight = 0f;
        //_colorParameter.value = Color.clear;
        //_fadeMaterial.color = Color.clear;
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

    /// <summary>
    /// Set environment active after fade black
    /// </summary>
    public void ShowEnvironment()
    {
        OnFadeBlackFinished -= ShowEnvironment;
        if (hiddenEnvironment != null)
        {
            foreach (GameObject env in hiddenEnvironment)
            {
                if (env != null)          // could be destroyed if Main reloaded
                {
                    env.SetActive(true);
                }
            }
            hiddenEnvironment = null;
        }
        FadeToWhite(true);
    }

    /// <summary>
    /// Set environment inactive after fade black
    /// </summary>
    public void HideEnvironment()
    {
        OnFadeBlackFinished -= HideEnvironment;
        hiddenEnvironment = GameObject.FindGameObjectsWithTag("Environment");
        foreach (GameObject env in hiddenEnvironment)
        {
            env.SetActive(false);
        }
    }

    #region Obsolete
    [Obsolete]
    public void HideIndicators()
    {
        OnFadeBlackStarted -= HideIndicators;
        foreach (ArtifactSnapBehaviour storage in storages)
        {
            activeStorages[storage] = storage.GetActiveState();
            storage.SetActiveState(false);
        }
    }

    [Obsolete]
    public void RestoreIndicators()
    {
        OnFadeWhiteFinished -= RestoreIndicators;
        foreach (ArtifactSnapBehaviour storage in storages)
        {
            storage.SetActiveState(activeStorages[storage]);
        }
    }
    #endregion

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
        //OnFadeWhiteFinished += RestoreIndicators;
        _fadeCoroutine = StartCoroutine(FadeWhite());
    }
    #endregion
}
