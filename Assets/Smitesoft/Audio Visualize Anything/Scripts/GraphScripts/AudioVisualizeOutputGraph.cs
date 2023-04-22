using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class AudioVisualizeOutputGraph : MonoBehaviour
{
    private Text MaxYText;
    private Text MinYText;

    public enum Graph
    {
        Enabled,
        Disabeled
    }
    [SerializeField] private Graph graph;

    private bool TogglePlot = true;
    public enum ScalingMode
    {
        AutoScale,
        Manual
    }
    [SerializeField] private ScalingMode scalingMode;

    [SerializeField] private float GraphYMaximum = .2f;
    private float LastTickYMaximum;

    [SerializeField] private float GraphYMinimum = 0f;
    private float LastTickYMinimum;

    [SerializeField] private float GraphXIncrement = 2f;

    [Range(1, 10)]
    [SerializeField] private int PlotsPerTick = 1;

    [SerializeField] private GameObject graphReference;   
    [SerializeField] private RectTransform graphContainerReference;
    [SerializeField] private Sprite marksSprite;

    List<float> OutputData = new List<float>();
    List<GameObject> pointsOnGraphList = new List<GameObject>();

    private void Awake()
    {
        LastTickYMaximum = GraphYMaximum;
        LastTickYMinimum = GraphYMinimum;

        switch (scalingMode)
        {
            case ScalingMode.AutoScale:                
                break;
            case ScalingMode.Manual:
                GraphYMaximum = 1;
                break;
            default:
                break;
        }

        //graphContainerReference = FindObjectOfType<graphContainerScript>().GetComponent<RectTransform>();

        if (graphReference != null)
        {
            MaxYText = graphReference.GetComponentInChildren<MaxYTextScript>(true).GetComponent<Text>();
            MinYText = graphReference.GetComponentInChildren<MinYTextScript>(true).GetComponent<Text>();
        }        

        //MaxYText = FindObjectOfType<MaxYTextScript>().GetComponent<Text>();  // not sure why TypeAll is being depricated
        //MinYText = FindObjectOfType<MinYTextScript>().GetComponent<Text>();

        switch (graph)
        {
            case Graph.Enabled:
                graphReference.SetActive(true);
                break;
            case Graph.Disabeled:
                graphReference.SetActive(false);
                break;
            default:
                break;
        }
    }

    public void OutputListener()
    {
        if (TogglePlot)
        {
            PopulateGraphList(AudioVisualizeManager.Output_Volume);
        }
    }

    public void PopulateGraphList(float Output)
    {
        CheckXBounds();

        CalculateMaxY(Output);
        OutputData.Add(Output);

        if (PlotsPerTick <= 0)
        {
            PlotsPerTick = 1;
        }

        if (LastTickYMaximum == GraphYMaximum && PlotsPerTick ==1) //This is much more effeciant, Consider getting rid of PlotsPerTick
        {                                                          //PlotsPerTick was initially intorduce to reduce processing, because we redrew the entire graph everytime. this is no longer the case, but only with PlotsPerTick ==1
            InjectGraphDataPoints(Output);
        }
        else
        {           
            if (OutputData.Count > 0 && OutputData.Count % PlotsPerTick == 0)  //Only do this id Y max Changes, otherwise Plot one at a time
            {
                foreach (var point in pointsOnGraphList)
                {
                    Destroy(point.gameObject);                                     //Should use object pooling for this
                }
                pointsOnGraphList.Clear();

                InjectGraphDataList(OutputData);

                LastTickYMaximum = GraphYMaximum;
            }
        } 
    }



    public void InjectGraphDataList(List<float> DataList) //we cycle through the list here and plot everyhing in it
    {
        float graphHeight = graphContainerReference.sizeDelta.y;

        for (int i = 0; i < DataList.Count; i++)
        {
            float xPosition = i * GraphXIncrement;
            float yPosition = (DataList[i] / GraphYMaximum ) * graphHeight / 2f;  //Devided by 2 because we want the middile of the graph to be 0
            
            yPosition += graphHeight / 2f;                                      //Shifting the Y Axes
            CreateCircle(new Vector2(xPosition, yPosition));
        }
    }

    public void InjectGraphDataPoints(float Data) // Plot each individually
    {
        float graphHeight = graphContainerReference.sizeDelta.y;

        float xPosition = OutputData.Count * GraphXIncrement;
        float yPosition = (Data / GraphYMaximum ) * graphHeight / 2f;  //Devided by 2 because we want the middile of the graph to be 0
        
        yPosition += graphHeight / 2f;   //this is middile of graph //Shifting the Y Axes        
        CreateCircle(new Vector2(xPosition, yPosition));
    }


    private void CreateCircle(Vector2 anchoredPosition)
    {
        GameObject gameObject = new GameObject("circle", typeof(Image));              //Overriding what gameObject means inside this function, it will no longer refere to the gameObject that this script it placed on
        gameObject.transform.SetParent(graphContainerReference, false);                        //omg, this does not refere to the gameobject this script is place on, it referes to the one I just created!!
        gameObject.GetComponent<Image>().sprite = marksSprite;                       //Need to add a Circle sprite
        pointsOnGraphList.Add(gameObject);

        RectTransform rectTransform = gameObject.GetComponent<RectTransform>();
        rectTransform.anchoredPosition = anchoredPosition;
        rectTransform.sizeDelta = new Vector2(11, 11);
        rectTransform.anchorMin = new Vector2(0, 0);
        rectTransform.anchorMax = new Vector2(0, 0);
    }



    public void CalculateMaxY(float Output)
    {
        if (GraphYMaximum < Mathf.Abs(Output))   
        {
            switch (scalingMode)
            {
                case ScalingMode.AutoScale:
                    GraphYMaximum = Mathf.Abs(Output);
                    break;
                case ScalingMode.Manual:
                    break;
                default:
                    break;
            }
        }
        MaxYText.text = GraphYMaximum.ToString();
        MinYText.text = (GraphYMaximum * (-1f)).ToString();


        //if (GraphYMaximum < Output)              //If I wwant to Upgrade this code later
        //{
        //    switch (scalingMode)
        //    {
        //        case ScalingMode.AutoScale:
        //            GraphYMaximum = Output;
        //            break;
        //        case ScalingMode.Manual:
        //            break;
        //        default:
        //            break;
        //    }
        //    MaxYText.text = GraphYMaximum.ToString();           
        //}
        //else
        //if (GraphYMinimum > Output)
        //{
        //    switch (scalingMode)
        //    {
        //        case ScalingMode.AutoScale:
        //            GraphYMinimum = Output;
        //            break;
        //        case ScalingMode.Manual:
        //            break;
        //        default:
        //            break;
        //    }
        //    MinYText.text = GraphYMinimum.ToString();
        //}


    }
    private void CheckXBounds()
    {
        if (graphContainerReference.sizeDelta.x - (OutputData.Count * GraphXIncrement) <= 0f)
        {
            OutputData.Clear();
            foreach (var point in pointsOnGraphList)
            {
                Destroy(point.gameObject);               //Should use object pooling for this
            }
            pointsOnGraphList.Clear();
        }
    }



    //Editor

    public void EnableDisableGraph() 
    {
        switch (graph)
        {
            case Graph.Enabled:
                graphReference.SetActive(true);
                break;
            case Graph.Disabeled:
                graphReference.SetActive(false);
                break;
            default:
                break;
        }
    }

    public void TogglePlotButton() //make this a button
    {
        if (TogglePlot)
        {
            TogglePlot = false;
        }
        else
        {
            TogglePlot = true;
        }
    }

    public void AutoScaleToggle()
    {       
        switch (scalingMode)
        {
            case ScalingMode.AutoScale:                
                float Ymax = 0;
                foreach (var Output in OutputData)
                {                    
                    if (Ymax < Mathf.Abs(Output))
                    {
                        Ymax = Mathf.Abs(Output);
                    }
                }
                GraphYMaximum = Ymax;
                break;
            case ScalingMode.Manual:
                break;
            default:
                break;
        }
    }


}
