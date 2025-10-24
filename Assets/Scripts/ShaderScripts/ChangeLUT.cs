using NUnit.Framework;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Rendering;

public class ChangeLUT : MonoBehaviour
{
    [SerializeField] private List<Texture> lutTex;
    [SerializeField] private Volume GlobalVol;

    private PlayerInput PlayerInput;


    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
