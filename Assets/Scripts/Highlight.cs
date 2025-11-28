using UnityEngine;

public class Highlight : Interactable
{
    public override void OnFocus()
    {
        GetComponent<Renderer>().materials[1].SetFloat("_enable", 1.0f);
    }
    public override void OnInteract()
    {
        
    }

    public override void OnLoseFocus()
    {
        GetComponent<Renderer>().materials[1].SetFloat("_enable", 0.0f);
    }

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
