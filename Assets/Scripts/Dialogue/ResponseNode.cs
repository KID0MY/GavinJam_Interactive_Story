
using UnityEngine;

[System.Serializable]
public class ResponseNode
{
    public string responseText;
    public DialogueNode nextNode;
    public bool eatCake = false;
    public bool eatPill = false;
    public bool photo = false;
    public bool ring = false;
    [Range(-1, 1)]
    public int karma;
}
