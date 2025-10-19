using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    [Header("Character movement Values")]
    public float moveSpeed = 10f;
    public float gravity = -9.81f;
    public float thrusterSpeed = 3f;

    [Header("References")]
    public CameraController cameraController;
    public Transform cameraBody;

    // Components
    private CharacterController controller; 
    private PlayerInput playerInput;

    // Movement
    private Vector2 moveInput;
    private Vector3 velocity;

    private void Awake()
    {
        controller = GetComponent<CharacterController>();
        playerInput = GetComponent<PlayerInput>();
    }

    // Input System callback
    public void OnMove(InputAction.CallbackContext context)
    {
        moveInput = context.ReadValue<Vector2>();
    }
    void Update()
    {
        HandleGravityMovement();
    }
    // Normal walking with gravity
    void HandleGravityMovement()
    {
        Vector3 move = transform.right * moveInput.x + transform.forward * moveInput.y;
        controller.Move(move * moveSpeed * Time.deltaTime);

        if (controller.isGrounded && velocity.y < 0)
            velocity.y = -2f; // stick to ground

        velocity.y += gravity * Time.deltaTime;
        controller.Move(velocity * Time.deltaTime);
    }
}
