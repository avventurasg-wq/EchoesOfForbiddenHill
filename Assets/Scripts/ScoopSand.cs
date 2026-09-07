using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScoopSand : MonoBehaviour
{
    //[SerializeField]
    //float sandSpeed;
    //[SerializeField]
    //float removeSpeed;
    //[SerializeField]
    //float removeDuration;
    [SerializeField]
    bool widenPileOnDig;

    [SerializeField]
    ParticleSystem sandParticle;

    Material material;
    // Start is called before the first frame update
    void Start()
    {
        material = GetComponent<MeshRenderer>().material;
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
            sandParticle.Stop();
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.transform.tag == "Digger")
        {
            ExcavationTool digger = other.transform.GetComponentInParent<ExcavationTool>();
            Debug.Log($"Digging {digger.isGrabbed}");
            if (!digger.isGrabbed)
            {
                return;
            }
            sandParticle.Play();
        }
    }
    private void OnTriggerStay(Collider other)
    {
        if (other.transform.tag == "Digger")
        {
            ExcavationTool digger = other.transform.GetComponentInParent<ExcavationTool>();
            Debug.Log($"Digging {digger.isGrabbed}");
            if (!digger.isGrabbed)
            {
                if (sandParticle.isPlaying)
                {
                    sandParticle.Stop();
                }
                return;
            }
            sandParticle.transform.position = other.ClosestPoint(transform.position);
            DigSand(digger.digSpeed, digger.sandDisturbance);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.transform.tag == "Digger")
        {
            sandParticle.Stop();
        }
    }

    /// <summary>
    /// Reduce sand pile size
    /// </summary>
    /// <param name="digSpeed"> Controls how quickly the sand pile decreases </param>
    /// <param name="sandSpeed"> Controls the amount of sand disturbance </param>
    void DigSand(float digSpeed, float sandSpeed)
    {

        if (transform.localScale.y < 0)
        {
            transform.localScale = Vector3.zero;
            return;
        }

        material.mainTextureOffset = new Vector2(0, material.mainTextureOffset.y + Time.deltaTime * sandSpeed);
        
        if (widenPileOnDig)
        {
            transform.localScale = new Vector3(transform.localScale.x + Time.deltaTime * digSpeed, transform.localScale.y - Time.deltaTime * digSpeed, transform.localScale.z + Time.deltaTime * digSpeed);
        }
        else
        {
            transform.localScale = new Vector3(transform.localScale.x, transform.localScale.y - Time.deltaTime * digSpeed, transform.localScale.z);
        }

        if (transform.localScale.y < 0)
        {
            transform.localScale = Vector3.zero;
            gameObject.SetActive(false);
            return;
        }
    }
}
