using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class Dialogue : MonoBehaviour
{
    public static Dialogue Instance {get; private set;}

    public GameObject DialogueParent; 
    public TextMeshProUGUI DialogTitleText, DialogBodyText; 
    public GameObject responseButtonPrefab;
    public Transform responseButtonContainer;

    private void Awake()
    {
        // ensures only one dialogue object exists at any one time
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }
        HideDialogue();
    }
    // set up Title and body text, instantiates buttons with response titles and listeners.
    public void StartDialogue(string title, DialogueNode node)
    {
        ShowDialogue();

        DialogTitleText.text = title;
        DialogBodyText.text = node.dialogueText;

        foreach (Transform child in responseButtonContainer)
        {
            Destroy(child.gameObject);
        }

        foreach (ResponseNode response in node.responses)
        {
            GameObject buttonObj = Instantiate(responseButtonPrefab, responseButtonContainer);
            buttonObj.GetComponentInChildren<TextMeshProUGUI>().text = response.responseText;

            buttonObj.GetComponent<Button>().onClick.AddListener(() => SelectResponse(response, title));
        }
    }

    // gets the dialogue branch from the chosen response and continues dialogue.
    public void SelectResponse(ResponseNode response, string title)
    {
        if (!response.nextNode.IsLastNode())
        {
            StartDialogue(title, response.nextNode);
        }
        else
        {
            HideDialogue();
        }
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

    //public TextMeshProUGUI text;
    //public PlayerController player;
    //public Button[] responseButtons;
    //private string[] lines;
    //private float textSpeed;

    //private int index;
    //private bool dialogueStarted = false;

    //// Start is called once before the first execution of Update after the MonoBehaviour is created
    //void Start()
    //{
    //    text.text = string.Empty;
    //}

    //// Update is called once per frame
    //void Update()
    //{

    //}

    //public void StartDialogue(string[] script, float speed, string[] Titles)
    //{
    //    if (dialogueStarted == false)
    //    {
    //        text.gameObject.SetActive(true);
    //        lines = script;
    //        textSpeed = speed;
    //        player.inDialogue = true;
    //        index = 0;
    //        dialogueStarted = true;
    //        StartCoroutine(TypeLine());
    //    }
    //    else 
    //    {
    //        if (text.text == lines[index])
    //        {
    //            NextLine();
    //        }
    //    }
    //}

    //public void NextLine()
    //{
    //    if (index < lines.Length - 1)
    //    {
    //        if (text.text == lines[index])
    //        {
    //            index++;
    //            text.text = string.Empty;
    //            StartCoroutine(TypeLine());
    //        }
    //        else
    //        {
    //            StopAllCoroutines();
    //            text.text = lines[index];
    //        }
    //    }
    //    //else
    //    //{
    //    //    if (text.text == lines[index])
    //    //    {
    //    //        StopAllCoroutines();
    //    //        Debug.Log("finished text");
    //    //        text.text = "";
    //    //        index = 0;
    //    //        dialogueStarted = false;
    //    //        player.inDialogue = false;
    //    //    }
    //    //    else
    //    //    {
    //    //        StopAllCoroutines();
    //    //        text.text = lines[index];
    //    //    }
    //    //}
    //}

    //public void Response(string[] script)
    //{
    //    index = 0;
    //    lines = script;
    //    NextLine();
    //}

    //IEnumerator TypeLine()
    //{
    //    foreach(char c in lines[index].ToCharArray())
    //    {
    //        text.text += c;
    //        yield return new WaitForSeconds(textSpeed);
    //    }
    //}
}
