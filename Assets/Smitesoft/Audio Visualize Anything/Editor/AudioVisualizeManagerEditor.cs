using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(AudioVisualizeManager))]
[CanEditMultipleObjects]
public class AudioVisualizeManagerEditor : Editor
{
    AudioVisualizeManager targetScript;

    SerializedProperty audioSource;
    SerializedProperty tottalAudioSampleLength;
    SerializedProperty maximumSampleValue;
    SerializedProperty minimumSampleValue;
    SerializedProperty Output;
    SerializedProperty maxOutputRecorded;
    SerializedProperty minOutputRecorded;

    SerializedProperty beat;
    SerializedProperty invokeMode;
    SerializedProperty blockSize;
    SerializedProperty algorithm;

    SerializedProperty multiplyByMinusOne;
    SerializedProperty refreshTime;
    SerializedProperty PushMultiplierPartOne;
    SerializedProperty PushMultiplierPartTwo;
    SerializedProperty tottalMultiplier;
    SerializedProperty ClampOutput;
    SerializedProperty minOutput;
    SerializedProperty maxOutput;

    SerializedProperty OnVolumeChange;
    SerializedProperty OnClipEnd;

    bool showEvents = true;

    public enum AudioStats
    {
        Detailed,
        Simple,
        None
    }
    [SerializeField] private AudioStats audioStats;

    private void OnEnable()
    {
        targetScript = (AudioVisualizeManager)target;

        audioSource = serializedObject.FindProperty("audioSource");

        tottalAudioSampleLength = serializedObject.FindProperty("tottalAudioSampleLength");
        maximumSampleValue = serializedObject.FindProperty("maximumSampleValue");
        minimumSampleValue = serializedObject.FindProperty("minimumSampleValue");
        Output = serializedObject.FindProperty("Output");
        maxOutputRecorded = serializedObject.FindProperty("maxOutputRecorded");
        minOutputRecorded = serializedObject.FindProperty("minOutputRecorded");

        beat = serializedObject.FindProperty("beat");
        invokeMode = serializedObject.FindProperty("invokeMode");
        blockSize = serializedObject.FindProperty("blockSize");
        algorithm = serializedObject.FindProperty("algorithm");

        multiplyByMinusOne = serializedObject.FindProperty("multiplyByMinusOne");
        refreshTime = serializedObject.FindProperty("refreshTime");
        PushMultiplierPartOne = serializedObject.FindProperty("PushMultiplierPartOne");
        PushMultiplierPartTwo = serializedObject.FindProperty("PushMultiplierPartTwo");
        tottalMultiplier = serializedObject.FindProperty("tottalMultiplier");
        ClampOutput = serializedObject.FindProperty("ClampOutput");
        minOutput = serializedObject.FindProperty("minOutput");
        maxOutput = serializedObject.FindProperty("maxOutput");

        OnVolumeChange = serializedObject.FindProperty("OnVolumeChange");
        OnClipEnd = serializedObject.FindProperty("OnClipEnd");
    }

    public override void OnInspectorGUI()
    {
        //base.OnInspectorGUI();
        serializedObject.Update();
        EditorGUI.BeginChangeCheck();

        EditorGUILayout.BeginVertical();

        EditorGUILayout.Space();
        EditorGUILayout.PropertyField(audioSource);
        EditorGUILayout.Space();

        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.Space();
        audioStats = (AudioStats)EditorGUILayout.EnumPopup("Audio Stats Mode:", audioStats);
        EditorGUILayout.Space();

        switch (audioStats)
        {
            case AudioStats.Detailed:
                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                EditorGUILayout.PropertyField(tottalAudioSampleLength);
                EditorGUILayout.PropertyField(maximumSampleValue);
                EditorGUILayout.PropertyField(minimumSampleValue);
                EditorGUILayout.EndVertical();

                EditorGUILayout.Space();

                EditorGUILayout.BeginVertical(EditorStyles.helpBox);
                EditorGUILayout.PropertyField(Output);
                EditorGUILayout.PropertyField(maxOutputRecorded);
                EditorGUILayout.PropertyField(minOutputRecorded);
                EditorGUILayout.EndVertical();
                break;
            case AudioStats.Simple:
                EditorGUILayout.PropertyField(Output);
                EditorGUILayout.PropertyField(maxOutputRecorded);
                EditorGUILayout.PropertyField(minOutputRecorded);
                break;
            case AudioStats.None:
                break;
            default:
                break;                
        }
        EditorGUILayout.Space();
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space();
        EditorGUILayout.Space();
        EditorGUILayout.Space();

        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.Space();
        EditorGUILayout.PropertyField(invokeMode);
        if (invokeMode.enumValueIndex == 1)
        {
            EditorGUILayout.Space();

            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.Space(); EditorGUILayout.Space();
            if (GUILayout.Button("Toggle Beat"))
            {
                targetScript.BeatToggle();
            }
            EditorGUILayout.Space(); EditorGUILayout.Space();
            EditorGUILayout.EndHorizontal();           
        }
        EditorGUILayout.Space();
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space();
        EditorGUILayout.Space();
        EditorGUILayout.Space();

        //EditorGUILayout.PropertyField(beat);

        //use a beat button instead here

        //EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.LabelField("Output Settings", EditorStyles.boldLabel);
        EditorGUILayout.Space();

        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.Space();
        EditorGUILayout.PropertyField(blockSize);
        EditorGUILayout.PropertyField(refreshTime);
        EditorGUILayout.Space();
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space();

        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.Space();
        EditorGUILayout.PropertyField(algorithm);
        EditorGUILayout.PropertyField(multiplyByMinusOne);
        EditorGUILayout.Space();
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space();

        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("Output Multiplier");
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.Space();
        EditorGUILayout.PropertyField(PushMultiplierPartOne, GUIContent.none);
        EditorGUILayout.PropertyField(PushMultiplierPartTwo, GUIContent.none);
        EditorGUILayout.Space();
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        GUI.enabled = false;
        EditorGUILayout.PropertyField(tottalMultiplier);
        GUI.enabled = true;
        EditorGUILayout.EndVertical();
        EditorGUILayout.Space();
        EditorGUILayout.EndVertical();

        EditorGUILayout.Space();
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);        
        EditorGUILayout.PropertyField(ClampOutput);
        
        if (ClampOutput.boolValue == true)
        {
            EditorGUILayout.Space();
            EditorGUILayout.PropertyField(minOutput);
            EditorGUILayout.PropertyField(maxOutput);
            EditorGUILayout.Space();
        }        
        EditorGUILayout.EndVertical();

        //EditorGUILayout.EndVertical();

        EditorGUILayout.Space();
        showEvents = EditorGUILayout.BeginFoldoutHeaderGroup(showEvents, "Events");
        if (showEvents)
        {
            EditorGUILayout.PropertyField(OnVolumeChange);
            EditorGUILayout.PropertyField(OnClipEnd);
        }
        EditorGUILayout.Space();
        EditorGUILayout.Space();

        EditorGUILayout.EndVertical();

        targetScript.RunEditorFunctions();

        if (EditorGUI.EndChangeCheck())
        {
            //targetScript.RunInEditor();            
            serializedObject.ApplyModifiedProperties();
            targetScript.AverageBlockVolumeCalc();
            //EditorWindow view = EditorWindow.focusedWindow;
            //view.Repaint();
        }
    }

}

