using System;
using System.Collections;
using System.Collections.Generic;
using Oculus.Interaction;
using Oculus.Interaction.HandGrab;
using UnityEngine;
using static Oculus.Interaction.AudioPhysics;

public class ExcavationTool : MonoBehaviour, ITransformer
{
    #region Serializables
    [SerializeField]
    public float digSpeed;
    [SerializeField]
    public float sandDisturbance;

    [SerializeField]
    private HandGrabInteractable _leftHandGrabInteractable;
    [SerializeField]
    private HandGrabInteractable _rightHandGrabInteractable;

    [SerializeField]
    private Rigidbody _rigidbody;
    [SerializeField]
    private AnimationCurve _collisionStrength;

    #endregion

    #region Properties
    Rigidbody rb;
    public bool isGrabbed { get; set; } = false;

    Vector3 lastGrabbedPos;
    Quaternion lastGrabbedRot;

    //private const float _timeBetweenCollisions = 0.1f;
    //private WaitForSeconds _hapticsWait = new WaitForSeconds(0.1f);

    private CollisionEvents _collisionEvents;
    //private float _timeAtLastCollision = 0f;

    protected bool _started = false;

    private OVRInput.Controller _activeController;
    private IGrabbable _grabbable;
    private Pose _grabDeltaInLocalSpace;

    #endregion

    #region Monobehaviours
    private void Awake()
    {
        //SetLastGrabTransform();
        if (GetComponent<Rigidbody>())
        {
            rb = GetComponent<Rigidbody>();
        }
        else
        {
            rb = GetComponentInChildren<Rigidbody>();
        }
    }
    protected virtual void Start()
    {
        this.BeginStart(ref _started);
        this.AssertField(_rigidbody, nameof(_rigidbody));
        _collisionEvents = _rigidbody.gameObject.AddComponent<CollisionEvents>();
        this.EndStart(ref _started);
    }


    protected virtual void OnEnable()
    {
        if (_started)
        {
            _collisionEvents.WhenCollisionEnter += HandleCollisionEnter;
            _leftHandGrabInteractable.WhenStateChanged += HandleLeftHandGrabInteractableStateChanged;
            _rightHandGrabInteractable.WhenStateChanged += HandleRightHandGrabInteractableStateChanged;
        }
    }

    protected virtual void OnDisable()
    {
        if (_started)
        {
            _collisionEvents.WhenCollisionEnter -= HandleCollisionEnter;
            _leftHandGrabInteractable.WhenStateChanged -= HandleLeftHandGrabInteractableStateChanged;
            _rightHandGrabInteractable.WhenStateChanged -= HandleRightHandGrabInteractableStateChanged;
        }
    }
    //private void OnTriggerEnter(Collider other)
    //{
    //    if (other.tag == "Respawn")
    //    {
    //        //rigidbody.useGravity = false;
    //        ResetVelocity();
    //        transform.position = lastGrabbedPos;
    //        transform.rotation = lastGrabbedRot;
    //        //rigidbody.useGravity = true;
    //    }
    //}
    #endregion

    #region ITransformer
    private void HandleLeftHandGrabInteractableStateChanged(InteractableStateChangeArgs stateChange)
    {
        if (stateChange.NewState == InteractableState.Select)
        {
            _activeController |= OVRInput.Controller.LTouch;
            //SetLastGrabTransform();
            isGrabbed = true;
        }
        else if (stateChange.PreviousState == InteractableState.Select)
        {
            _activeController &= ~OVRInput.Controller.LTouch;
            isGrabbed = false;
        }
    }

    private void HandleRightHandGrabInteractableStateChanged(InteractableStateChangeArgs stateChange)
    {
        if (stateChange.NewState == InteractableState.Select)
        {
            _activeController |= OVRInput.Controller.RTouch;
            //SetLastGrabTransform();
            isGrabbed = true;
        }
        else if (stateChange.PreviousState == InteractableState.Select)
        {
            _activeController &= ~OVRInput.Controller.RTouch;
            isGrabbed = false;
        }
    }

    private void HandleCollisionEnter(Collision collision)
    {
        //TryPlayCollisionAudio(collision);
    }

    //private void TryPlayCollisionAudio(Collision collision)
    //{
    //    float collisionMagnitude = collision.relativeVelocity.sqrMagnitude;

    //    if (collision.collider.gameObject == null)
    //    {
    //        return;
    //    }

    //    float deltaTime = Time.time - _timeAtLastCollision;
    //    if (_timeBetweenCollisions > deltaTime)
    //    {
    //        return;
    //    }

    //    _timeAtLastCollision = Time.time;

    //    PlayCollisionHaptics(collisionMagnitude);
    //}

    //private void PlayCollisionHaptics(float strength)
    //{
    //    float pitch = _collisionStrength.Evaluate(strength);
    //    StartCoroutine(HapticsRoutine(pitch, _activeController));
    //}

    //private IEnumerator HapticsRoutine(float pitch, OVRInput.Controller controller)
    //{
    //    OVRInput.SetControllerVibration(pitch * 0.5f, pitch * 0.2f, controller);
    //    yield return _hapticsWait;
    //    OVRInput.SetControllerVibration(0, 0, controller);
    //}

    public void Initialize(IGrabbable grabbable)
    {
        _grabbable = grabbable;
    }

    public void BeginTransform()
    {
        Pose grabPoint = _grabbable.GrabPoints[0];
        Transform targetTransform = _rigidbody.transform;
        _grabDeltaInLocalSpace = new Pose(targetTransform.InverseTransformVector(grabPoint.position - targetTransform.position),
                                        Quaternion.Inverse(grabPoint.rotation) * targetTransform.rotation);
    }

    public void UpdateTransform()
    {
        Pose grabPoint = _grabbable.GrabPoints[0];
        _rigidbody.MoveRotation(grabPoint.rotation * _grabDeltaInLocalSpace.rotation);
        _rigidbody.MovePosition(grabPoint.position - _rigidbody.transform.TransformVector(_grabDeltaInLocalSpace.position));
    }

    public void EndTransform()
    {

    }
    #endregion

    [Obsolete("Use snap interactor timeout to reset position")]
    public void SetLastGrabTransform()
    {
        lastGrabbedPos = transform.position;
        lastGrabbedRot = transform.rotation;
    }

    public void ResetVelocity()
    {
        rb.velocity = Vector3.zero;
        rb.angularVelocity = Vector3.zero;
    }
}
