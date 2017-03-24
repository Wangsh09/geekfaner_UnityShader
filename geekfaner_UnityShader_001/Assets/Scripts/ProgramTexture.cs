using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ProgramTexture : MonoBehaviour {

    public Material material = null;

    #region Material properties
    [SerializeField, SetProperty("textureWidth")]
    private int m_textureWidth = 16;
    public int textureWidth
    {
        get
        {
            return m_textureWidth;
        }
        set
        {
            m_textureWidth = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("backgroundColor")]
    private Color m_backgroundColor = Color.white;
    public Color backgroundColor
    {
        get
        {
            return m_backgroundColor;
        }
        set
        {
            m_backgroundColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("circleColor")]
    private Color m_circleColor = Color.yellow;
    public Color circleColor
    {
        get
        {
            return m_circleColor;
        }
        set
        {
            m_circleColor = value;
            _UpdateMaterial();
        }
    }
    #endregion

    private Texture2D m_generatedTexture = null;

    // Use this for initialization
    void Start () {
		if(material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if(renderer == null)
            {
                Debug.Log("No Renderer!");
                return;
            }

            material = renderer.sharedMaterial;
        }

        _UpdateMaterial();
    }

    private void _UpdateMaterial()
    {
        if(material != null)
        {
            m_generatedTexture = _GenerateProgramTexture();
            material.SetTexture("_MainTex", m_generatedTexture);
        }
    }

    private Texture2D _GenerateProgramTexture()
    {
        Texture2D programTexture = new Texture2D(textureWidth, textureWidth);

        float circleInterval = textureWidth / 4.0f;

        float radius = textureWidth / 10.0f;

        for(int w = 0; w < textureWidth; w++)
        {
            for(int h = 0; h < textureWidth; h++)
            {
                Color pixel = backgroundColor;

                for (int i = 0; i < 3; i++)
                {
                    for(int j = 0; j < 3; j++)
                    {
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));

                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;

                        if (dist <= 0)
                            pixel = circleColor;
                    }
                }

                programTexture.SetPixel(w, h, pixel);
            }
        }

        programTexture.Apply();

        return programTexture;
    }


	// Update is called once per frame
	void Update () {
		
	}
}
