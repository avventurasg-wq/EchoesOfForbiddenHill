using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScoopSand : MonoBehaviour
{
    [SerializeField]
    float sandSpeed;
    [SerializeField]
    float removeSpeed;
    [SerializeField]
    float removeDuration;

    bool isDecreasing;
    Material material;
    // Start is called before the first frame update
    void Start()
    {
        material = GetComponent<MeshRenderer>().material;
    }

    // Update is called once per frame
    void Update()
    {
    }

    private void OnMouseDown()
    {
        StartCoroutine(DecreaseSand());
    }

    IEnumerator DecreaseSand()
    {
        if (transform.localScale.y < 0 || isDecreasing)
        {
            yield break;
        }
        float elapsed = 0;
        isDecreasing = true;
        while (elapsed < removeDuration)
        {
            material.mainTextureOffset = new Vector2(0, material.mainTextureOffset.y + Time.deltaTime * sandSpeed);
            transform.localScale = new Vector3 (transform.localScale.x, transform.localScale.y - Time.deltaTime * removeSpeed, transform.localScale.z);
            if (transform.localScale.y < 0)
            {
                transform.localScale = Vector3.zero;
                break;
            }
            elapsed += Time.deltaTime;
            yield return null;
        }
        isDecreasing = false;

    }
}
