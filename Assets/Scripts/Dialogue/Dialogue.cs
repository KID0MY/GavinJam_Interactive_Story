using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;
using Unity.VisualScripting;

public class Dialogue : MonoBehaviour
{
    public static Dialogue Instance {get; private set;}

    public GameObject DialogueParent; 
    public TextMeshProUGUI DialogTitleText, DialogBodyText; 
    public GameObject responseButtonPrefab;
    public Transform responseButtonContainer;
    public PlayerController player;

    public float TextSpeed;

    private int index;
    private bool inDialogue;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        DialogBodyText.text = string.Empty;
        HideDialogue();
    }
    // set up Title and body text, instantiates buttons with response titles and listeners.
    public void StartDialogue(string title, DialogueNode node)
    {
        ShowDialogue();

        DialogTitleText.text = node.dialogueLines[index].name;
        DialogBodyText.text = node.dialogueLines[index].Line;
        StartCoroutine(TypeLine(node));

        foreach (Transform child in responseButtonContainer)
        {
            Destroy(child.gameObject);
        }

        if (index >= node.dialogueLines.Length - 1)
        {
            foreach (ResponseNode response in node.responses)
            {
                GameObject buttonObj = Instantiate(responseButtonPrefab, responseButtonContainer);
                buttonObj.GetComponentInChildren<TextMeshProUGUI>().text = response.responseText;

                buttonObj.GetComponent<Button>().onClick.AddListener(() => SelectResponse(response, title));
            }
        }
        else
        {
            GameObject buttonObj = Instantiate(responseButtonPrefab, responseButtonContainer);
            buttonObj.GetComponentInChildren<TextMeshProUGUI>().text = "Next";

            buttonObj.GetComponent<Button>().onClick.AddListener(() => NextLine(title, node));
        }
    }

    void NextLine(string title, DialogueNode node)
    {
        if (index < node.dialogueLines.Length)
        {
            index++;
            StartDialogue(title, node);
            Debug.Log(index);
        }
        else if (node.responses.Count == 0 && index >= node.dialogueLines.Length - 1)
        {
            index = 0;
            HideDialogue();
        }
    }

    // gets the dialogue branch from the chosen response and continues dialogue.
    public void SelectResponse(ResponseNode response, string title)
    {
        index = 0;
        if (!response.nextNode.IsLastNode())
        {
            StartDialogue(title, response.nextNode);
        }
        else
        {
            HideDialogue();
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }
        if (response.eatCake || response.eatPill || response.photo)
        {
            player.trueActs++;
        }
        player.karma += response.karma;
    }

    public void HideDialogue()
    {
        DialogueParent.SetActive(false);
    }


    private void ShowDialogue()
    {
        DialogueParent.SetActive(true);
    }

    public bool IsDialogueActive()
    {
        return DialogueParent.activeSelf;
    }

    IEnumerator TypeLine(DialogueNode node)
    {
        DialogBodyText.maxVisibleCharacters = 0;
        foreach (char c in node.dialogueLines[index].Line.ToCharArray())
        {
            DialogBodyText.maxVisibleCharacters++;
            yield return new WaitForSeconds(TextSpeed);
        }
    }
}
