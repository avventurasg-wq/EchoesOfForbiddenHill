using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class RandomMaterialAssignment : EditorWindow
{

    [SerializeField]
    List<MeshRenderer> meshList = new List<MeshRenderer>();

    [SerializeField]
    List<Material> matList = new List<Material>();

    [MenuItem("Tools/Assign Materials")]
    public static void ShowWindow()
    {
        RandomMaterialAssignment window = GetWindow<RandomMaterialAssignment>();
        window.titleContent = new GUIContent("Assign materials");
        window.Show();
    }

    private void OnGUI()
    {
        ScriptableObject target1 = this;
        SerializedObject so1 = new SerializedObject(target1);
        SerializedProperty stringsProperty1 = so1.FindProperty("meshList");

        EditorGUILayout.PropertyField(stringsProperty1, true);
        so1.ApplyModifiedProperties();

        ScriptableObject target2 = this;
        SerializedObject so2 = new SerializedObject(target2);
        SerializedProperty stringsProperty = so2.FindProperty("matList");

        EditorGUILayout.PropertyField(stringsProperty, true);
        so2.ApplyModifiedProperties();


        GUILayout.FlexibleSpace();
        if (GUILayout.Button("Assign"))
        {
            AssignMaterials();
        }
    }

    public void AssignMaterials()
    {
        foreach (MeshRenderer renderer in meshList)
        {
            int targetMat = Random.Range(0, matList.Count);
            renderer.material = matList[targetMat];
        }
    }
}
