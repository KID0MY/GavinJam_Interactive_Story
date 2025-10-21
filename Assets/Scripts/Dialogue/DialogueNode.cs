using NUnit.Framework;
using System;
using System.Collections.Generic;

[System.Serializable]
public class DialogueNode
{
    public string[] dialogueLines;
    public List<ResponseNode> responses;

    internal bool IsLastNode()
    {
        return responses.Count <= 0;
    }
}
