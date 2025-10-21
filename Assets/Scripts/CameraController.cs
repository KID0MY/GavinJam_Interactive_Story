using UnityEngine;
using UnityEngine.InputSystem;

public class CameraController : MonoBehaviour
{
    [Header("Camera Sensitivity")]
    [Range(0.0f, 30.0f)] public float lookSensitivity = 10.0f;
    [Range(0.0f, 100.0f)] public float rollSensitivity = 60.0f;
    [Range(100.0f, 300.0f)] public float controllerSensitivity = 200.0f;

    [Header("References")]
    public Transform playerBody;   // for gravity mode (Y rotation)
    public Transform cameraBody;   // actual camera

    private Vector2 lookInput;
    private float rollInput;
    private float xRotation = 0f;

    // Mode
    public bool zeroG = false; // toggled by PlayerController when switching maps

    private void OnEnable()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    public void OnLook(InputAction.CallbackContext context)
    {
        // Detect control scheme
        if (context.control.device is Mouse)
        {
            lookInput = context.ReadValue<Vector2>() * lookSensitivity;
        }
        else if (context.control.device is Gamepad)
        {
            lookInput = context.ReadValue<Vector2>() * controllerSensitivity;
        }
    }

    private void Update()
    {
        if (Cursor.lockState == CursorLockMode.Locked)
            HandleLookGravity();
    }

    void HandleLookGravity()
    {
        float mouseX = lookInput.x * Time.deltaTime;
        float mouseY = lookInput.y * Time.deltaTime;

        xRotation -= mouseY;
        xRotation = Mathf.Clamp(xRotation, -80f, 80f); // no flipping

        cameraBody.localRotation = Quaternion.Euler(xRotation, 0f, 0f);
        playerBody.Rotate(Vector3.up * mouseX);
    }
}
