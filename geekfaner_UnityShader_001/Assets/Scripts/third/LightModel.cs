using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightModel : MonoBehaviour{

    Material material;

    private Vector4 _diffuse;
    private Vector4 _specular;

    void Awake()
    {
        material = gameObject.GetComponent<MeshRenderer>().sharedMaterial;
        _diffuse = Vector4.one;
        _specular = Vector4.one;
    }

    void Update()
    {
        transform.Rotate(Vector3.up * Time.deltaTime * 10);
    }

	public void IsVertexDiffuse(bool check)
    {
        if (check)
            material.SetFloat("_vertex_diffuse", 1.0f);
        else
            material.SetFloat("_vertex_diffuse", 0.0f);
    }

    public void IsFragmentDiffuse(bool check)
    {
        if (check)
            material.SetFloat("_fragment_diffuse", 1.0f);
        else
            material.SetFloat("_fragment_diffuse", 0.0f);
    }

    public void IsLambert(bool check)
    {
        if (check)
            material.SetFloat("_Lambert", 1.0f);
        else
            material.SetFloat("_Lambert", 0.0f);
    }

    public void IsVertexSpecular(bool check)
    {
        if (check)
            material.SetFloat("_vertex_specular", 1.0f);
        else
            material.SetFloat("_vertex_specular", 0.0f);
    }

    public void IsFragmentSpecular(bool check)
    {
        if (check)
            material.SetFloat("_fragment_specular", 1.0f);
        else
            material.SetFloat("_fragment_specular", 0.0f);
    }

    public void IsPhong(bool check)
    {
        if (check)
            material.SetFloat("_Phong", 1.0f);
        else
            material.SetFloat("_Phong", 0.0f);
    }

    public void ChangeDiffuseR(float value)
    {
        _diffuse.x = value;
        material.SetColor("_Diffuse", _diffuse);
    }

    public void ChangeDiffuseG(float value)
    {
        _diffuse.y = value;
        material.SetColor("_Diffuse", _diffuse);
    }

    public void ChangeDiffuseB(float value)
    {
        _diffuse.z = value;
        material.SetColor("_Diffuse", _diffuse);
    }

    public void ChangeSpecularR(float value)
    {
        _specular.x = value;
        material.SetColor("_Specular", _specular);
    }

    public void ChangeSpecularG(float value)
    {
        _specular.y = value;
        material.SetColor("_Specular", _specular);
    }

    public void ChangeSpecularB(float value)
    {
        _specular.z = value;
        material.SetColor("_Specular", _specular);
    }

    public void ChangeGloss(float value)
    {
        material.SetFloat("_Gloss", value * 100);
    }

    public void IsObjectNormal(bool check)
    {
        if (check)
            material.SetFloat("_object_normal", 1.0f);
        else
            material.SetFloat("_object_normal", 0.0f);
    }

    public void ChangeBumpScale(float value)
    {
        material.SetFloat("_BumpScale", value * 2 - 1);
    }

    public void IsRamp(bool check)
    {
        if (check)
            material.SetFloat("_ramp_tex", 1.0f);
        else
            material.SetFloat("_ramp_tex", 0.0f);
    }

    public void IsAlphaTest(bool check)
    {
        Texture2D alpha_test = (Texture2D)Resources.Load("Texture/alpha_test", typeof(Texture2D));
        Texture2D airplane = (Texture2D)Resources.Load("Texture/FX_waterfall4", typeof(Texture2D));
        if (check)
        {
            material.SetFloat("_alpha_test", 1.0f);
            material.SetTexture("_MainTex", alpha_test);
        }
        else
        {
            material.SetFloat("_alpha_test", 0.0f);
            material.SetTexture("_MainTex", airplane);
        }
    }

    public void ChangeAlphaThreshold(float value)
    {
        material.SetFloat("_alpha_threshold", value);
    }

    public void IsAlphaBlend(bool check)
    {
        if (check)
        {
            material.SetFloat("_alpha_blend", 1.0f);
        }
        else
        {
            material.SetFloat("_alpha_blend", 0.0f);
        }
    }

    public void IsCull(bool check)
    {
        if (check)
            material.SetFloat("_cull", 1.0f);
        else
            material.SetFloat("_cull", 0.0f);
    }

    public void IsVertexLit(bool check)
    {
        if (check)
            material.SetFloat("_vertex_lit", 1.0f);
        else
            material.SetFloat("_vertex_lit", 0.0f);
    }

    public void IsFragmentLit(bool check)
    {
        if (check)
            material.SetFloat("_fragment_lit", 1.0f);
        else
            material.SetFloat("_fragment_lit", 0.0f);
    }

    public void IsAtten(bool check)
    {
        if (check)
            material.SetFloat("_atten", 1.0f);
        else
            material.SetFloat("_atten", 0.0f);
    }

    public void IsShadow(bool check)
    {
        if (check)
            material.SetFloat("_shadow", 1.0f);
        else
            material.SetFloat("_shadow", 0.0f);
    }

    public void IsRim(bool check)
    {
        if (check)
            material.SetFloat("_rim", 1.0f);
        else
            material.SetFloat("_rim", 0.0f);
    }
}
