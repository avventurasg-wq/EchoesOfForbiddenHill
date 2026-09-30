using UnityEngine;

public class LampMovement : MonoBehaviour
{
    #region Serializables
    [SerializeField]
    float minForce;
    [SerializeField]
    float maxForce;
    [SerializeField]
    float interval;
    #endregion

    #region Properties
    Rigidbody rb;
    #endregion

    #region Monobehaviours
    // Start is called before the first frame update
    void Start()
    {
        rb = GetComponent<Rigidbody>();
        InvokeRepeating(nameof(BlowLamp), 0f, interval);
    }
    #endregion

    /// <summary>
    /// Add force to swing lamp
    /// </summary>
    void BlowLamp()
    {
        float force = Random.Range(minForce, maxForce);
        Vector3 windDir = new Vector3(Random.Range(-1f, 1f), 0, Random.Range(-1f, 1f)).normalized;
        rb.AddForce(windDir * force);
    }
}
