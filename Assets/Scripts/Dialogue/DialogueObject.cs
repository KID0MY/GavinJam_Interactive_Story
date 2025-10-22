using Unity.VisualScripting;
using UnityEngine;

public class DialogueObject : Interactable
{
    public string Name;
    public bool startDialogue;
    public bool Item;
    public DialogueScriptable diaScriptable;
    public Dialogue dialogueBox;
    public PlayerController player;

    private void Start()
    {
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
        FindAnyObjectByType(typeof(DialogueObject)).GameObject().SetActive(true);
        Dialogue.Instance.StartDialogue(Name, diaScriptable.DiaNode);
    }

    public override void OnInteract()
    {
        SpeakTo();
        Destroy(this);
        if (Item)
        {
            player.itemsInteracted++;
        }
        Debug.Log("cake");
    }

    public override void OnFocus()
    {
        
    }

    public override void OnLoseFocus()
    {
        
    }
}
