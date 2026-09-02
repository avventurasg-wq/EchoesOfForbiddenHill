using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Events;

public class WashText : MonoBehaviour
{
    #region Serializable
    [SerializeField]
    float washDuration;
    [SerializeField]
    float stretchSpeed;
    [SerializeField]
    float dropDelay;
    [SerializeField]
    float dropSpeed;
    #endregion

    TextMeshPro text;

    #region Event
    public UnityEvent washEvent = new UnityEvent();
    #endregion

    #region Monobehaviour
    private void Awake()
    {
        text = GetComponent<TextMeshPro>();
    }
    #endregion

    #region Public Methods
    /// <summary>
    /// Start washing coroutine
    /// </summary>
    public void StartWashing()
    {
        StartCoroutine(WashAway());
    }

    /// <summary>
    /// Coroutine to mimic text being washed from wall
    /// </summary>
    /// <returns></returns>
    IEnumerator WashAway()
    {
        float elapsed = 0;
        while (elapsed < washDuration)
        {
            transform.localScale = transform.localScale + Vector3.up * Time.deltaTime * stretchSpeed;
            if (elapsed < 1)
            {
                text.fontMaterial.SetFloat(ShaderUtilities.ID_OutlineSoftness, elapsed);
            }
            if (elapsed > dropDelay)
            {
                transform.Translate(0, -1 * Time.deltaTime * dropSpeed, 0);
            }
            elapsed += Time.deltaTime;
            yield return null;
        }
    }
    #endregion
}
