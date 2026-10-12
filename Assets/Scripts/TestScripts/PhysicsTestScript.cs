using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UIElements;

public class PhysicsTestScript : MonoBehaviour
{
    [SerializeField]
    float moveSpeed;
    [SerializeField]
    float turnSpeed;

    [SerializeField]
    InputActionReference rotateLeft;
    [SerializeField]
    InputActionReference rotateRight;
    [SerializeField]
    InputActionReference moveForward;
    [SerializeField]
    InputActionReference moveBack;
    [SerializeField]
    InputActionReference moveLeft;
    [SerializeField]
    InputActionReference moveRight;
    [SerializeField]
    InputActionReference moveUp;
    [SerializeField]
    InputActionReference moveDown;

    Rigidbody rb;

    Vector3 targetPos = Vector3.zero;
    Quaternion targetRot = Quaternion.identity;

    float maxGap;
    float startGap;
    // Start is called before the first frame update
    void Start()
    {
        rotateLeft.action.performed += TurnLeft;
        rotateRight.action.performed += TurnRight;
        moveForward.action.performed += MoveForward;
        moveBack.action.performed += MoveBack;
        moveLeft.action.performed += MoveLeft;
        moveRight.action.performed += MoveRight;
        moveUp.action.performed += MoveUp;
        moveDown.action.performed += MoveDown;

        rotateLeft.action.canceled += CancelRot;
        rotateRight.action.canceled += CancelRot;
        moveForward.action.canceled += CancelFront;
        moveBack.action.canceled += Cancelback;
        moveLeft.action.canceled += CancelLeft;
        moveRight.action.canceled += CancelRight;
        moveUp.action.canceled += CancelUp;
        moveDown.action.canceled += CancelDown;

        rb = GetComponent<Rigidbody>();
        if (rb == null)
        {
            Destroy(this);
        }

    }

    private void Update()
    {
        rb.Move(rb.position + (targetPos * moveSpeed * Time.deltaTime), rb.rotation * targetRot);
        //float gap = Vector3.Magnitude(point2.position - point1.position);
        //gap = Mathf.Abs(gap);
        //if (gap > maxGap)
        //{
        //    maxGap = gap;
        //}
        //Debug.Log($"Gap: {gap}\nMax: {maxGap} Start: {startGap}");
        //Debug.Log($"Velocity: {rb.velocity}\nAngular Velocity: {rb.angularVelocity}");
    }

    private void OnDestroy()
    {
        rotateLeft.action.performed -= TurnLeft;
        rotateRight.action.performed -= TurnRight;
        moveForward.action.performed -= MoveForward;
        moveBack.action.performed -= MoveBack;
        moveLeft.action.performed -= MoveLeft;
        moveRight.action.performed -= MoveRight;
        moveUp.action.performed -= MoveUp;
        moveDown.action.performed -= MoveDown;

        rotateLeft.action.canceled -= CancelRot;
        rotateRight.action.canceled -= CancelRot;
        moveForward.action.canceled -= CancelFront;
        moveBack.action.canceled -= Cancelback;
        moveLeft.action.canceled -= CancelLeft;
        moveRight.action.canceled -= CancelRight;
        moveUp.action.canceled -= CancelUp;
        moveDown.action.canceled -= CancelDown;
    }

    private void OnApplicationQuit()
    {
        rotateLeft.action.performed -= TurnLeft;
        rotateRight.action.performed -= TurnRight;
        moveForward.action.performed -= MoveForward;
        moveBack.action.performed -= MoveBack;
        moveLeft.action.performed -= MoveLeft;
        moveRight.action.performed -= MoveRight;
        moveUp.action.performed -= MoveUp;
        moveDown.action.performed -= MoveDown;

        rotateLeft.action.canceled -= CancelRot;
        rotateRight.action.canceled -= CancelRot;
        moveForward.action.canceled -= CancelFront;
        moveBack.action.canceled -= Cancelback;
        moveLeft.action.canceled -= CancelLeft;
        moveRight.action.canceled -= CancelRight;
        moveUp.action.canceled -= CancelUp;
        moveDown.action.canceled -= CancelDown;
    }

    void TurnLeft(InputAction.CallbackContext callbackContext)
    {
        //rotateRight.action.Reset();
        //float turn = -turnSpeed * Time.deltaTime;
        //Quaternion rotation = Quaternion.Euler(0,turn,0);
        //targetRot = rotation;
    }

    void TurnRight(InputAction.CallbackContext callbackContext)
    {
        //rotateLeft.action.Reset();
        //float turn = turnSpeed * Time.deltaTime;
        //Quaternion rotation = Quaternion.Euler(0,turn,0);
        //targetRot = rotation;
    }
    void CancelRot(InputAction.CallbackContext callbackContext)
    {
        //rotateLeft.action.Reset();
        //rotateRight.action.Reset();
        //targetRot = Quaternion.identity;
    }

    void MoveForward(InputAction.CallbackContext callbackContext)
    {
        moveBack.action.Reset();
        targetPos += Vector3.forward;
    }

    void CancelFront(InputAction.CallbackContext callbackContext)
    {
        moveForward.action.Reset();
        targetPos -= Vector3.forward;
    }

    void MoveBack(InputAction.CallbackContext callbackContext)
    {
        moveForward.action.Reset();
        targetPos += Vector3.back;
    }

    void Cancelback(InputAction.CallbackContext callbackContext)
    {
        moveBack.action.Reset();
        targetPos -= Vector3.back;
    }

    void MoveLeft(InputAction.CallbackContext callbackContext)
    {
        moveRight.action.Reset();
        targetPos += Vector3.left;
    }

    void CancelLeft(InputAction.CallbackContext callbackContext)
    {
        moveLeft.action.Reset();
        targetPos -= Vector3.left;
    }

    void MoveRight(InputAction.CallbackContext callbackContext)
    {
        moveLeft.action.Reset();
        targetPos += Vector3.right;
    }

    void CancelRight(InputAction.CallbackContext callbackContext)
    {
        moveRight.action.Reset();
        targetPos -= Vector3.right;
    }

    void MoveUp(InputAction.CallbackContext callbackContext)
    {
        moveRight.action.Reset();
        targetPos += Vector3.up;
    }

    void CancelUp(InputAction.CallbackContext callbackContext)
    {
        moveLeft.action.Reset();
        targetPos -= Vector3.up;
    }

    void MoveDown(InputAction.CallbackContext callbackContext)
    {
        moveLeft.action.Reset();
        targetPos += Vector3.down;
    }

    void CancelDown(InputAction.CallbackContext callbackContext)
    {
        moveRight.action.Reset();
        targetPos -= Vector3.down;
    }


}
