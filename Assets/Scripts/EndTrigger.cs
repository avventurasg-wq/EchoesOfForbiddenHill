using System.Collections;
using System.Collections.Generic;
using Oculus.Interaction;
using Oculus.Interaction.HandGrab;
using UnityEngine.SceneManagement;
using UnityEngine;

public class EndTrigger : MonoBehaviour
{
    #region Serializables
    [SerializeField]
    HandGrabInteractable handGrabInteractable;   // hands
    [SerializeField]
    GrabInteractable grabInteractable;           // controllers
    #endregion

    #region Monobehaviours
    //private void OnEnable()
    //{
    //    handGrabInteractable.WhenStateChanged += HandleStateChanged;
    //    grabInteractable.WhenStateChanged += HandleStateChanged;
    //}

    //private void OnDisable()
    //{
    //    handGrabInteractable.WhenStateChanged -= HandleStateChanged;
    //    grabInteractable.WhenStateChanged -= HandleStateChanged;
    //}
    #endregion

    #region Private Methods
    /// <summary>
    /// End the game when the ladder is grabbed
    /// </summary>
    void HandleStateChanged(InteractableStateChangeArgs args)
    {
        if (args.NewState != InteractableState.Select)
        {
            return;
        }
        //Debug.Log("restart");
        GameFlowManager.Instance.RestartGame();
    }
    #endregion

    #region Public Method
    public void RestartGame()
    {
        GameFlowManager.Instance.RestartGame();
        //Debug.Log("restart");
    }
    #endregion
}
