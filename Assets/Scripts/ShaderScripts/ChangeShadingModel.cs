using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class ChangeShadingModel : MonoBehaviour
{
    [SerializeField] private List<Material> shadingMaterials = new List<Material>();
    [SerializeField] private List<GameObject> computers = new List<GameObject>();
    private PlayerInput playerInput;
    private bool numkeyNum;

    public InputActionAsset inputActions;
    private InputActionMap actionMap;
    private float OnScrollMouse;
    
    private void Awake()
    {
        // Load all computers tagged as "Computer"
        GameObject[] foundComputers = GameObject.FindGameObjectsWithTag("computer");
        computers.AddRange(foundComputers);
        Debug.Log($"Found {computers.Count} computers.");
        actionMap = inputActions.FindActionMap("PlayerMovement", true);
    }

    void OnEnable()
    {
        actionMap.Enable();

        for (int i = 1; i <= 6; i++)
        {
            var action = actionMap.FindAction($"{i}", false);
            if (action != null)
            {
                int index = i - 1;
                action.performed += ctx => ChangeMaterial(index);
            }
        }
    }
    void OnDisable()
    {
        for (int i = 1; i <= 6; i++)
        {
            var action = actionMap.FindAction($"{i}", false);
            if (action != null)
            {
                int index = i - 1;
                action.performed -= ctx => ChangeMaterial(index);
            }
        }
        actionMap.Disable();
    }

    private void ChangeMaterial(int index)
    {
        if (index < 0 || index >= shadingMaterials.Count)
        {
            Debug.LogWarning($"No material assigned for key {index + 1}");
            return;
        }

        Material mat = shadingMaterials[index];

        foreach (GameObject comp in computers)
        {
            Renderer rend = comp.GetComponent<Renderer>();
            if (rend != null)
                rend.material = mat;
        }

        Debug.Log($"Changed all 'Computer' objects to material {index + 1} ({mat.name}).");
    }
}
