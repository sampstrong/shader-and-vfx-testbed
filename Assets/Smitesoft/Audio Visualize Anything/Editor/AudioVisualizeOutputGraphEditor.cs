using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


[CustomEditor(typeof(AudioVisualizeOutputGraph))]
[CanEditMultipleObjects]
public class AudioVisualizeOutputGraphEditor : Editor
{
    AudioVisualizeOutputGraph targetScript;

    SerializedProperty graph;
    SerializedProperty scalingMode;
    SerializedProperty GraphYMaximum;
    SerializedProperty GraphXIncrement;
    SerializedProperty PlotsPerTick;
    SerializedProperty graphReference;
    SerializedProperty graphContainerReference;
    SerializedProperty marksSprite;

    bool references;

    private void OnEnable()
    {
        targetScript = (AudioVisualizeOutputGraph)target;

        graph = serializedObject.FindProperty("graph");
        scalingMode = serializedObject.FindProperty("scalingMode");
        GraphYMaximum = serializedObject.FindProperty("GraphYMaximum");
        GraphXIncrement = serializedObject.FindProperty("GraphXIncrement");
        PlotsPerTick = serializedObject.FindProperty("PlotsPerTick");
        graphReference = serializedObject.FindProperty("graphReference");
        graphContainerReference = serializedObject.FindProperty("graphContainerReference");
        marksSprite = serializedObject.FindProperty("marksSprite");
        
    }

    public override void OnInspectorGUI()
    {
        //base.OnInspectorGUI();

        serializedObject.Update();
        EditorGUI.BeginChangeCheck();

        EditorGUILayout.BeginVertical();

        EditorGUILayout.Space();
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.Space();
        EditorGUILayout.PropertyField(graph);
        EditorGUILayout.Space();

        if (graph.enumValueIndex==0)
        {
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.Space();
            EditorGUILayout.Space();
            if (GUILayout.Button("Plot : Pause/Resume"))
            {
                targetScript.TogglePlotButton();
            }
            EditorGUILayout.Space();
            EditorGUILayout.Space();
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Space();
            EditorGUILayout.EndVertical();
            EditorGUILayout.Space();


            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.Space();
            EditorGUILayout.PropertyField(scalingMode);
            if (scalingMode.enumValueIndex == 1)
            {
                EditorGUILayout.PropertyField(GraphYMaximum);
            }            
            EditorGUILayout.Space();
            EditorGUILayout.EndVertical();

            EditorGUILayout.Space();

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.Space();
            EditorGUILayout.PropertyField(GraphXIncrement);
            EditorGUILayout.PropertyField(PlotsPerTick);
            EditorGUILayout.Space();
            EditorGUILayout.EndVertical();

            EditorGUILayout.Space();

            references = EditorGUILayout.BeginFoldoutHeaderGroup(references, "References");
            if (references)
            {
                EditorGUILayout.Space();
                EditorGUILayout.PropertyField(graphReference);
                EditorGUILayout.PropertyField(graphContainerReference);
                EditorGUILayout.PropertyField(marksSprite);
                EditorGUILayout.Space();
            }

            
        }
        else
        {
            EditorGUILayout.EndVertical();
        }

        



        EditorGUILayout.EndVertical();

        //targetScript.RunEditorFunctions();

        if (EditorGUI.EndChangeCheck())
        {
            serializedObject.ApplyModifiedProperties();
            //targetScript.RunInEditor();            

            //EditorWindow view = EditorWindow.focusedWindow;
            //view.Repaint();

            targetScript.EnableDisableGraph(); //Always Remember to not spam an enum in the target script, put it here  
                                               //IMPORTANT** Make sure you set this after "serializedObject.ApplyModifiedProperties();"

            targetScript.AutoScaleToggle();
        }
    }
}
