using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Profiling;

public class Necklace : MonoBehaviour
{
    [SerializeField]
    List<NecklacePhysics> leftPortions;
    [SerializeField]
    List<NecklacePhysics> rightPortions;
    [SerializeField]
    Rigidbody target;


    [SerializeField]
    float spring;
    [SerializeField]
    float damper;

    public float leftLength = 0;
    public float rightLength = 0;

    public float targetLimit = 0;

    // Start is called before the first frame update
    void Start()
    {
        foreach (NecklacePhysics portion in leftPortions)
        {
            leftLength += portion.gapLimit;
        }
        foreach (NecklacePhysics portion in rightPortions)
        {
            rightLength += portion.gapLimit;
        }

        leftLength += (leftPortions[leftPortions.Count - 1].transform.position - target.position).magnitude;
        rightLength += (rightPortions[leftPortions.Count - 1].transform.position - target.position).magnitude;

        targetLimit = Mathf.Min(leftLength, rightLength);
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 gap = target.position - transform.position;
        float distanceDiscrepancy = targetLimit - gap.magnitude;

        target.position += distanceDiscrepancy * gap.normalized;

        Vector3 velocityTarget = gap + (target.velocity + Physics.gravity * spring);
        Vector3 projectOnConnection = Vector3.Project(velocityTarget, gap);
        target.velocity = (velocityTarget - projectOnConnection) / (1 + damper * Time.fixedDeltaTime);
    }
}
