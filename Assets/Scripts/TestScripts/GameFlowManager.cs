using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;


#region GameStateEnum
public enum GameState
{
    MainMenu,
    Loading,
    Playing,
    Video,

    Paused,
    GameOver
}
#endregion

public class GameFlowManager : MonoBehaviour
{
    #region Singleton
    public static GameFlowManager Instance { get; private set; }
    #endregion

    #region Serializables
    [SerializeField]
    float endWaitSeconds = 30f;

    [SerializeField]
    float sphereDisplaySeconds = 10f;    // how long the ending sphere is shown
    [SerializeField]
    GameObject endingSphere;             // must be in the Manager scene
    Coroutine endRoutine;
    #endregion

    #region State
    private GameState currentState;
    public GameState CurrentState => currentState;
    #endregion

    private int sceneIndex = 1;

    #region MonoBehaviour
    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(this);
        }
        else
        {
            Instance = this;
        }
    }

    void Start()
    {
        SetState(GameState.Loading);
        StartCoroutine(LoadMainScene());
        SceneManager.sceneLoaded += OnSceneLoaded;
    }

    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        if (scene.buildIndex == sceneIndex)
        {
            SetState(GameState.Playing);
        }
        SceneManager.SetActiveScene(SceneManager.GetSceneByBuildIndex(sceneIndex));
#if UNITY_EDITOR
        DynamicGI.UpdateEnvironment();
#endif

        if (FadeManager.Instance != null)
        {
            FadeManager.Instance.FadeToWhite(true);
        }
    }

    void Update()
    {
        //Debug.Log("Current State: " + currentState);
        if (Keyboard.current != null && Keyboard.current.digit0Key.wasPressedThisFrame)
        {
            Debug.Log("[Flow] Debug key 0 pressed");
            RestartGame();
        }
    }
    public void SetState(GameState newState)
    {
        currentState = newState;
    }

    // Update is called once per frame
    public void StartGame()
    {
        if (currentState != GameState.MainMenu)
        {
            return;
        }
        SetState(GameState.Loading);
        FadeManager.Instance.OnFadeBlackFinished += OnFadedToBlackForStart;
        FadeManager.Instance.FadeToBlack(true);
    }

    public void EndGame()
    {
        if (currentState != GameState.Playing)
        {
            return;
        }
        SetState(GameState.GameOver);

        FadeManager.Instance.OnFadeBlackFinished += OnFadedToBlackForEnd;
        FadeManager.Instance.FadeToBlack(true);
    }
    public void RestartGame()
    {
        if (endRoutine != null)
        {
            StopCoroutine(endRoutine);
            endRoutine = null;
        }
        if (currentState == GameState.MainMenu || currentState == GameState.Loading)
        {
            return;
        }

        if (ArtifactManager.Instance != null)
        {
            ArtifactManager.Instance.ResetProgress();
        }

        SetState(GameState.Loading);
        Debug.Log("[Flow] Fade to black finished, reloading");
        FadeManager.Instance.OnFadeBlackFinished += OnFadedToBlackForRestart;
        FadeManager.Instance.FadeToBlack(true);
    }

    private void OnFadedToBlackForStart()
    {
        FadeManager.Instance.OnFadeBlackFinished -= OnFadedToBlackForStart;
        StartCoroutine(LoadMainScene());
    }
    private void OnFadedToBlackForRestart()
    {
        FadeManager.Instance.OnFadeBlackFinished -= OnFadedToBlackForRestart;
        StartCoroutine(ReloadMainScene());
    }
    private void OnFadedToBlackForEnd()
    {
        FadeManager.Instance.OnFadeBlackFinished -= OnFadedToBlackForEnd;
        endRoutine = StartCoroutine(EndGameRoutine());
    }
    #endregion

    #region Coroutines
    IEnumerator LoadMainScene()
    {
        AsyncOperation load = SceneManager.LoadSceneAsync(sceneIndex, LoadSceneMode.Additive);
        yield return load;

        // SceneManager.SetActiveScene(SceneManager.GetSceneByBuildIndex(sceneIndex));
        // SetState(GameState.Playing);

        // if (FadeManager.Instance != null)
        // {
        //     FadeManager.Instance.FadeToWhite(true);
        // }
    }

    IEnumerator ReloadMainScene()
    {
        endingSphere.SetActive(false);
        FadeManager.Instance.hiddenEnvironment = null;
        VideoManager.Instance.ResetVideoState();
        Scene mainScene = SceneManager.GetSceneByBuildIndex(sceneIndex);
        if (mainScene.isLoaded)
        {
            AsyncOperation unload = SceneManager.UnloadSceneAsync(sceneIndex);
            yield return unload;
        }
        yield return StartCoroutine(LoadMainScene());

    }

    IEnumerator EndGameRoutine()
    {
        // 1. screen is black → wait
        yield return new WaitForSeconds(endWaitSeconds);

        // 2. turn off environment, turn on ending sphere
        FadeManager.Instance.HideEnvironment();
        endingSphere.SetActive(true);

        // 3. fade in so the player can actually see the sphere
        FadeManager.Instance.FadeToWhite(true);
        yield return new WaitForSeconds(sphereDisplaySeconds);

        // 4. THEN reset the game and clear watched state
        endRoutine = null;
        if (ArtifactManager.Instance != null)
        {
            ArtifactManager.Instance.ResetProgress();
        }
        RestartGame();
    }
    #endregion
}
