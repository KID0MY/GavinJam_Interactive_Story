using UnityEngine;

public abstract class Interactable : MonoBehaviour
{
    public abstract void OnInteract();
    public abstract void OnFocus();
    public abstract void OnLoseFocus();
    // Start is called once before the first execution of Update after the MonoBehaviour is created
}
