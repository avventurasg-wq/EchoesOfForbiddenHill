using UnityEditor;
using UnityEngine;
using System;
using System.Collections.Generic;
using HISPlayerAPI;

// ============================================
// Custom Inspector for Specific Platform WebGL
// ============================================
public static class HISPlayerInspectorGUI_WebGL
{
    // Centralized field definitions for WebGL
    private static readonly List<FieldConfig> fieldConfigs = new()
    {
        // Web GL Mode
        new FieldConfig {
            propertyName = "webGLMode",
            label = "WebGL Mode",
            type = FieldType.Simple,
            tooltip = "WebGL Mode"
        },

        // Ads Properties
        new FieldConfig {
            propertyName = "adsProperties",
            label = "Ads Properties",
            type = FieldType.Foldout,
            tooltip = "Properties to configure advertisement insertions for each player in the scene",
            condition = (element) =>
            {
                var mode = (WebGLMode)element.FindPropertyRelative("webGLMode").enumValueIndex;
                return mode == WebGLMode.Default;
            }
        },

        // Starting Bitrate
        new FieldConfig {
            propertyName = "startingBitrate",
            label = "Starting Bitrate",
            type = FieldType.Simple,
            tooltip = "The bitrate in bps the player will try to start playing. Setting it to 0 starts with the lowest track.",
            condition = (element) =>
            {
                var mode = (WebGLMode)element.FindPropertyRelative("webGLMode").enumValueIndex;
                return mode == WebGLMode.Default;
            }
        },

        // Custom Bitrate
        new FieldConfig {
            propertyName = "customBitrate",
            label = "Custom Bitrate",
            type = FieldType.Simple,
            tooltip = "Enable custom bitrate range",
            condition = (element) =>
            {
                var mode = (WebGLMode)element.FindPropertyRelative("webGLMode").enumValueIndex;
                return mode == WebGLMode.Default;
            }
        },

        // Track Bitrate Range
        new FieldConfig {
            propertyName = "trackBitrateRange",
            label = "Track Bitrate Range",
            type = FieldType.Simple,
            tooltip = "Limits tracks by bitrate range (X=Min, Y=Max in bps)",
            condition = (element) =>
            {
                var mode = (WebGLMode)element.FindPropertyRelative("webGLMode").enumValueIndex;
                return mode == WebGLMode.Default && element.FindPropertyRelative("customBitrate").boolValue;
            }
        },

        // Custom Max Size
        new FieldConfig {
            propertyName = "customMaxSize",
            label = "Custom Max Size",
            type = FieldType.Simple,
            tooltip = "Enable custom max size",
            condition = (element) =>
            {
                var mode = (WebGLMode)element.FindPropertyRelative("webGLMode").enumValueIndex;
                return mode == WebGLMode.Default;
            }
        },

        // Resolution Max Size
        new FieldConfig {
            propertyName = "resolutionMaxSize",
            label = "Resolution Max Size",
            type = FieldType.Simple,
            tooltip = "Limits the tracks by maximum resolution (X=Width, Y=Height in px)",
            condition = (element) =>
            {
                var mode = (WebGLMode)element.FindPropertyRelative("webGLMode").enumValueIndex;
                return mode == WebGLMode.Default && element.FindPropertyRelative("customMaxSize").boolValue;
            }
        },

        // Custom Min Size
        new FieldConfig {
            propertyName = "customMinSize",
            label = "Custom Min Size",
            type = FieldType.Simple,
            tooltip = "Enable custom min size",
            condition = (element) =>
            {
                var mode = (WebGLMode)element.FindPropertyRelative("webGLMode").enumValueIndex;
                return mode == WebGLMode.Default;
            }
        },

        // Resolution Min Size
        new FieldConfig {
            propertyName = "resolutionMinSize",
            label = "Resolution Min Size",
            type = FieldType.Simple,
            tooltip = "Limits the tracks by minimum resolution (X=Width, Y=Height in px)",
            condition = (element) =>
            {
                var mode = (WebGLMode)element.FindPropertyRelative("webGLMode").enumValueIndex;
                return mode == WebGLMode.Default && element.FindPropertyRelative("customMinSize").boolValue;
            }
        }
    };

    public static bool Draw(float x, float y, float width, SerializedProperty element, bool isExpanded, out float newY)
    {
        // Main foldout for WebGL settings
        Rect foldoutRect = new(x, y, width, EditorGUIUtility.singleLineHeight);

        // Copied the same style from reorderableList
        // This is the background 
        GUIStyle roundHeader = new GUIStyle("RL Header");
        int distFixWebGL = 14;
        roundHeader.fixedWidth = width + distFixWebGL;
        isExpanded = EditorGUI.Foldout(foldoutRect, isExpanded, GUIContent.none, true, roundHeader);

        // This is the header
        GUIStyle foldoutHeader = new GUIStyle("Foldout");
        foldoutHeader.fontStyle = FontStyle.Bold;
        Rect arrowRect = new Rect(foldoutRect.x + 4, foldoutRect.y, foldoutRect.width, foldoutRect.height);
        EditorGUI.Foldout(arrowRect, isExpanded, "Platform WebGL", false, foldoutHeader);

        y += EditorGUIUtility.singleLineHeight;

        if (isExpanded)
        {
            EditorGUI.indentLevel++;

            // Background added manually
            y += 2; // Fixed high from RL Backgound
            int distBackgroundXFix = 13;
            int distBackgroundWidthFix = 14;
            float contentHeight = GetTotalHeight(element);
            Rect backgroundRect = new Rect(x - distBackgroundXFix, y, width + distBackgroundWidthFix, contentHeight);
            GUI.Box(backgroundRect, GUIContent.none, "RL Background");

            float lineHeight = EditorGUIUtility.singleLineHeight;
            y += 3;     // Separation from the Header
            width -= 8; // Margin

            foreach (var config in fieldConfigs)
            {
                if (!config.visible) continue;
                if (config.condition != null && !config.condition(element)) continue;

                switch (config.type)
                {
                    case FieldType.Simple:
                        var sp = element.FindPropertyRelative(config.propertyName);
                        if (sp != null)
                        {
                            float height = EditorGUI.GetPropertyHeight(sp, true);
                            EditorGUI.PropertyField(
                                new Rect(x, y, width, height),
                                sp, new GUIContent(config.label ?? sp.displayName, config.tooltip), true
                            );
                            lineHeight = height;

                            y += lineHeight + config.extraSpacing;
                        }
                        break;

                    case FieldType.Foldout:
                        var fold = element.FindPropertyRelative(config.propertyName);
                        if (fold != null)
                        {
                            float height = EditorGUI.GetPropertyHeight(fold, fold.isExpanded);
                            EditorGUI.PropertyField(
                                new Rect(x, y, width, height),
                                fold, new GUIContent(config.label ?? fold.displayName, config.tooltip), true
                            );
                            y += height + config.extraSpacing;
                        }
                        break;

                    case FieldType.Label:
                        var style = config.boldLabel ? EditorStyles.boldLabel : EditorStyles.label;
                        EditorGUI.LabelField(
                            new Rect(x, y, width, lineHeight),
                            config.label, style
                        );
                        y += lineHeight + config.extraSpacing;
                        break;

                    case FieldType.Custom:
                        // Reserved for custom WebGL logic (if needed later)
                        break;
                }
            }
            EditorGUI.indentLevel--;
        }

        newY = y;
        return isExpanded;
    }

    public static float GetTotalHeight(SerializedProperty element)
    {
        float total = 4;
        float lineHeight = EditorGUIUtility.singleLineHeight;

        foreach (var config in fieldConfigs)
        {
            if (!config.visible) continue;
            if (config.condition != null && !config.condition(element)) continue;

            switch (config.type)
            {
                case FieldType.Simple:
                    var sp = element.FindPropertyRelative(config.propertyName);
                    if (sp != null)
                        total += EditorGUI.GetPropertyHeight(sp, true) + config.extraSpacing;
                    break;

                case FieldType.Foldout:
                    var fold = element.FindPropertyRelative(config.propertyName);
                    if (fold != null)
                        total += EditorGUI.GetPropertyHeight(fold, fold.isExpanded) + config.extraSpacing;
                    break;

                case FieldType.Label:
                    total += lineHeight + config.extraSpacing;
                    break;

                case FieldType.Custom:
                    total += lineHeight + config.extraSpacing;
                    break;
            }
        }

        return total;
    }
}
