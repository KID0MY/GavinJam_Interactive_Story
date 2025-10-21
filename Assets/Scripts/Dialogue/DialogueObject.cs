using UnityEngine;

public class DialogueObject : Interactable
{
    public string Name;
    public bool fix;
    public bool startDialogue;
    public DialogueScriptable diaScriptable;

    private void Start()
    {
        if (fix)
            SpeakTo();
        if (startDialogue)
        {
            SpeakTo(); SpeakTo();
        }
    }

    // Trigger dialogue for this object
    public void SpeakTo()
    {
        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;
        Dialogue.Instance.StartDialogue(Name, diaScriptable.DiaNode);
    }

    public override void OnInteract()
    {
        SpeakTo();
        Debug.Log("cake");
    }

    public override void OnFocus()
    {
        
    }

    public override void OnLoseFocus()
    {
        
    }
}
