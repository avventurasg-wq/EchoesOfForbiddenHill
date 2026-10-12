using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NecklacePhysics : MonoBehaviour
{
    [SerializeField]
    float adjSpeed;
    [SerializeField]
    float spring;
    [SerializeField]
    float damper;

    [SerializeField]
    bool rotatePivot;

    [SerializeField]
    bool fixedPosition = true;

    [SerializeField]
    bool smoothening;

    [SerializeField]
    UpAxis upAxis;
    
    public float gapLimit;

    enum UpAxis
    {
        Default,
        Up,
        Down,
        Left,
        Right,
        Forward,
        Back
    }

    [SerializeField]
    Transform pivot;

    Rigidbody rb;

    // Start is called before the first frame update
    void Awake()
    {
        //parentRb = GetComponentInParent<Rigidbody>();
        rb = GetComponent<Rigidbody>();
        gapLimit = (rb.position - pivot.position).magnitude;
    }



    // Update is called once per frame
    void FixedUpdate()
    {
        if (!pivot)
        {
            return;
            //connectRigidbody = joints.Count - 1;
        }

        if (fixedPosition)
        {
            Vector3 gap = rb.position - pivot.position;
            float distanceDiscrepancy = gapLimit - gap.magnitude;

            rb.position += distanceDiscrepancy * gap.normalized;

            Vector3 velocityTarget = gap + (rb.velocity + Physics.gravity * spring);
            Vector3 projectOnConnection = Vector3.Project(velocityTarget, gap);
            rb.velocity = (velocityTarget - projectOnConnection) / (1 + damper * Time.fixedDeltaTime);
        }

        if (!rotatePivot)
        {
            return;
        }
        Vector3 direction = rb.position - pivot.position;
        Vector3 rotate;
        float speed = smoothening ?  adjSpeed * Time.fixedDeltaTime : adjSpeed;
        switch (upAxis)
        {
            case UpAxis.Up:
                rotate = Vector3.RotateTowards(pivot.up, direction, speed, 0);
                pivot.up = rotate;
                break;
            case UpAxis.Down:
                rotate = Vector3.RotateTowards(pivot.up, -direction, speed, 0);
                pivot.up = rotate;
                break;
            case UpAxis.Left:
                rotate = Vector3.RotateTowards(pivot.right, -direction, speed, 0);
                pivot.right = rotate;
                break;
            case UpAxis.Right:
                rotate = Vector3.RotateTowards(pivot.right, direction, speed, 0);
                pivot.right = rotate;
                break;
            case UpAxis.Forward:
                rotate = Vector3.RotateTowards(pivot.forward, direction, speed, 0);
                pivot.forward = rotate;
                break;
            case UpAxis.Back:
                rotate = Vector3.RotateTowards(pivot.forward, -direction, speed, 0);
                pivot.forward = rotate;
                break;
            default:
                rotate = Vector3.RotateTowards(pivot.up, direction, speed, 0);
                pivot.up = rotate; 
                break;
        }
    }
}
