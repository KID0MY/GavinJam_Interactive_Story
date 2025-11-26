using UnityEngine;
using UnityEngine.SceneManagement;

public class Menu_Code : MonoBehaviour
{
    bool paused = false;

    public GameObject Menu;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
    }

    public void pauseMenu()
    {
        paused = !paused;
        Time.timeScale = paused ? 0 : 1;
        Cursor.lockState = paused? CursorLockMode.Confined : CursorLockMode.Locked;
        Cursor.visible = paused;
        Menu.SetActive(paused);
    }
    
    public void StartGame()
    {
        SceneManager.LoadScene("MAIN_GameScene");
    }

    public void ExitGame()
    {
        Application.Quit();
    }
}
