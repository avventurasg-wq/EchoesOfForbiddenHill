using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using Oculus.Interaction.HandGrab;
using UnityEngine;

public class ScoopSand : MonoBehaviour
{
    #region Serializables
    [SerializeField]
    Transform artifact;

    [SerializeField]
    bool isScaleMode;

    [SerializeField]
    bool widenPileOnDig;

    [SerializeField]
    float digDepth;

    [SerializeField]
    float uncoverDepth;
    [SerializeField]
    bool useArtifactPivot;

    [SerializeField]
    Transform sand;

    [SerializeField]
    ParticleSystem sandParticle;
    #endregion

    #region Properties
    Material material;
    float startingY;
    float targetDepth;
    float releaseDepth;
    #endregion

    Action DiscoverArtifact;

    #region Monobehaviour
    // Start is called before the first frame update
    void Start()
    {
        material = sand.GetComponent<MeshRenderer>().material;
        startingY = transform.parent.position.y;
        targetDepth = startingY - digDepth;
        releaseDepth = startingY - uncoverDepth;

        DiscoverArtifact += CheckArtifact;
    }

    private void OnEnable()
    {
        artifact.GetComponent<Rigidbody>().isKinematic = true;
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.transform.tag == "Digger")
        {
            ExcavationTool digger = collision.transform.GetComponent<ExcavationTool>();
            Debug.Log($"Digging {digger.isGrabbed}");
            if (!digger.isGrabbed)
            {
                return;
            }
            collision.transform.GetComponent<AudioSource>().Play();
            sandParticle.Play();
        }
    }

    private void OnCollisionStay(Collision collision)
    {
        if (collision.transform.tag == "Digger")
        {
            ExcavationTool digger = collision.transform.GetComponent<ExcavationTool>();
            Debug.Log($"Digging {digger.isGrabbed}");
            if (!digger.isGrabbed)
            {
                if (sandParticle.isPlaying)
                {
                    collision.transform.GetComponent<AudioSource>().Stop();
                    sandParticle.Stop();
                }
                return;
            }
            sandParticle.transform.position = collision.contacts[0].point;
            DigSand(digger.digSpeed, digger.sandDisturbance);

        }
    }

    private void OnCollisionExit(Collision collision)
    {
        if (collision.transform.tag == "Digger")
        {
            collision.transform.GetComponent<AudioSource>().Stop();
            sandParticle.Stop();
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.transform.tag == "Digger")
        {
            ExcavationTool digger = other.transform.GetComponentInParent<ExcavationTool>();
            //Debug.Log($"Digging {digger.isGrabbed}");
            if (!digger.isGrabbed)
            {
                return;
            }
            other.transform.GetComponent<AudioSource>().Play();
            sandParticle.Play();
        }
    }
    private void OnTriggerStay(Collider other)
    {
        if (other.transform.tag == "Digger")
        {
            ExcavationTool digger = other.transform.GetComponentInParent<ExcavationTool>();
            //Debug.Log($"Digging {digger.isGrabbed}");
            if (!digger.isGrabbed)
            {
                if (sandParticle.isPlaying)
                {
                    other.transform.GetComponent<AudioSource>().Stop();
                    sandParticle.Stop();
                }
                return;
            }

            //sandParticle.transform.position = other.ClosestPoint(transform.position);
            DigSand(digger.digSpeed, digger.sandDisturbance);
            DiscoverArtifact?.Invoke();
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.transform.tag == "Digger")
        {
            other.transform.GetComponent<AudioSource>().Stop();
            sandParticle.Stop();
        }
    }
    #endregion

    #region Private Methods
    /// <summary>
    /// Reduce sand pile size
    /// </summary>
    /// <param name="digSpeed"> Controls how quickly the sand pile decreases </param>
    /// <param name="sandSpeed"> Controls the amount of sand disturbance </param>
    void DigSand(float digSpeed, float sandSpeed)
    {
        if (isScaleMode)
        {
            if (sand.localScale.y < 0)
            {
                sand.localScale = Vector3.zero;
                return;
            }


            if (widenPileOnDig)
            {
                sand.localScale = new Vector3(sand.localScale.x + Time.deltaTime * digSpeed, sand.localScale.y - Time.deltaTime * digSpeed, sand.localScale.z + Time.deltaTime * digSpeed);
            }
            else
            {
                sand.localScale = new Vector3(sand.localScale.x, sand.localScale.y - Time.deltaTime * digSpeed, sand.localScale.z);
            }

            if (sand.localScale.y < 0)
            {
                sand.localScale = Vector3.zero;
                gameObject.SetActive(false);
                return;
            }
        }
        else
        {
            if (transform.parent.position.y < targetDepth)
            {
                return;
            }


            transform.parent.position = new Vector3(transform.parent.position.x, transform.parent.position.y - Time.deltaTime * digSpeed * 0.5f, transform.parent.position.z);

            if (transform.parent.position.y < targetDepth)
            {
                gameObject.SetActive(false);
                return;
            }
        }
        material.mainTextureOffset = new Vector2(0, material.mainTextureOffset.y + Time.deltaTime * sandSpeed);

    }

    /// <summary>
    /// Checks if target point is still buried
    /// </summary>
    void CheckArtifact()
    {
        if (useArtifactPivot)
        {
            bool inside = GetComponent<Collider>().ClosestPoint(artifact.position) == artifact.position;
            if (!inside)
            {
                artifact.GetComponentInChildren<HandGrabInteractable>().enabled = true;
                DiscoverArtifact -= CheckArtifact;
                Debug.Log($"Artifact released: {artifact.name}");
            }
        }
        else
        {
            if (transform.parent.position.y < releaseDepth)
            {
                artifact.GetComponentInChildren<HandGrabInteractable>().enabled = true;
                DiscoverArtifact -= CheckArtifact;
                Debug.Log($"Artifact released: {artifact.name}");
            }

        }
    }
    #endregion
}
