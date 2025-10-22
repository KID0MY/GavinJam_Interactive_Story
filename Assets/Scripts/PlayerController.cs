using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;

public class PlayerController : MonoBehaviour
{
    public int karma = 0;
    public List<Interactable> Endings;
    public int itemsInteracted = 0;
    public Transform endPos;
    bool gameEnd;

    [Header("Character movement Values")]
    public float moveSpeed = 10f;
    public float gravity = -9.81f;
    public float thrusterSpeed = 3f;

    [Header("References")]
    public CameraController cameraController;
    public Transform cameraBody;
    public Camera playerCamera;

    [Header("Interaction values")]
    [SerializeField] private Vector3 interactionRayPoint = default;
    [SerializeField] private float interactionDistance = default;
    [SerializeField] private LayerMask interactionLayer = default;
    private Interactable currentInteractable;

    [HideInInspector]
    public bool inDialogue;

    [HideInInspector]
    public int trueActs = 0;

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
    public void OnInteract(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            if (currentInteractable != null && Physics.Raycast(playerCamera.ViewportPointToRay(interactionRayPoint), out RaycastHit hit, interactionDistance, interactionLayer))
            {
                currentInteractable.OnInteract();
            }
        }
    }
    void Update()
    {
        HandleGravityMovement();
        InteractionCheck();
        if (itemsInteracted == 5 && !gameEnd)
        {
            endGame();
        }
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
    private void InteractionCheck()
    {
        if (Physics.Raycast(playerCamera.ViewportPointToRay(interactionRayPoint), out RaycastHit hit, interactionDistance))
        {
            if (currentInteractable == null || hit.collider.gameObject.GetInstanceID() != currentInteractable.GetInstanceID())
            {
                hit.collider.TryGetComponent(out currentInteractable);
                Debug.Log("raycast works");
                if (currentInteractable)
                {
                    currentInteractable.OnFocus();
                }
            }
        }
        else if (currentInteractable)
        {
            currentInteractable.OnLoseFocus();
            currentInteractable = null;
        }
    }
    void endGame()
    {
        if (karma < 0 && trueActs < 4)
        {
            Endings[2].OnInteract();
        }
        else if (karma >= 0 && trueActs < 4)
        {
            Endings[3].OnInteract();
        }
        else if (trueActs >= 4)
        {
            SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
        }
    }
}
