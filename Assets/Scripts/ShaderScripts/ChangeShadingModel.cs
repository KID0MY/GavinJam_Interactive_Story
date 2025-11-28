using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class ChangeShadingModel : MonoBehaviour
{
    [SerializeField] private List<Material> shadingMaterials = new List<Material>();
    [SerializeField] private List<GameObject> computers = new List<GameObject>();
    private PlayerInput playerInput;

    public InputActionAsset inputActions;
    private InputActionMap actionMap;

    private void Awake()
    {
        // Load all computers tagged as "computer"
        GameObject[] foundComputers = GameObject.FindGameObjectsWithTag("computer");
        computers.AddRange(foundComputers);
        Debug.Log($"Found {computers.Count} computers.");

        actionMap = inputActions.FindActionMap("PlayerMovement", true);
    }

    void OnEnable()
    {
        actionMap.Enable();

        // Bind number keys 1–6
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
            {
                // Get a copy of all materials
                Material[] mats = rend.materials;

                if (mats.Length > 1)
                {
                    // Replace ONLY material index 1
                    mats[1] = mat;

                    // Assign updated material array back
                    rend.materials = mats;
                }
                else
                {
                    Debug.LogWarning($"{comp.name} does not have a second material slot.");
                }
            }
        }

        Debug.Log($"Changed material element 1 on all 'computer' objects to {mat.name}");
    }
}
