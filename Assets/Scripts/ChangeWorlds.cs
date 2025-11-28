using UnityEngine;
using UnityEngine.InputSystem;

public class ChangeWorlds : MonoBehaviour
{
    private PlayerInput playerInput;
    private bool isUp = false;

    [SerializeField] private float teleportHeight = 5f;
    private Vector3 originalPosition;

    private Rigidbody rb;
    private CharacterController controller;

    void Start()
    {
        playerInput = GetComponent<PlayerInput>();
        originalPosition = transform.position;

        rb = GetComponent<Rigidbody>();
        controller = GetComponent<CharacterController>();
    }

    public void OnTeleport(InputAction.CallbackContext context)
    {
        if (!context.performed) return;

        Vector3 targetPos;

        if (!isUp)
        {
            targetPos = transform.position + Vector3.up * teleportHeight;
            isUp = true;
        }
        else
        {
            targetPos = transform.position + Vector3.up * -teleportHeight;
            isUp = false;
        }

        // --- Teleport handling ---
        if (rb != null)
        {
            // Disable physics for the teleport frame
            rb.isKinematic = true;
            rb.position = targetPos;
            rb.isKinematic = false;
        }
        else if (controller != null)
        {
            // Teleport using CharacterController
            controller.enabled = false;
            transform.position = targetPos;
            controller.enabled = true;
        }
        else
        {
            // No Rigidbody or CharacterController, just move transform
            transform.position = transform.position;
        }
    }
}