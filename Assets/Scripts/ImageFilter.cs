using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[ImageEffectAllowedInSceneView]
public class ImageFilter : MonoBehaviour
{
	public Material filter;

	[Range(0f,1f)] public float should = 0f;

	void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		filter.SetFloat("_Should", should);
		
		Graphics.Blit(source, destination, filter);
	}
}
