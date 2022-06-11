using Godot;
using System;
using System.Collections.Generic;
using GraphPlanarityTesting.Graphs.DataStructures;
using GraphPlanarityTesting.PlanarityTesting.BoyerMyrvold;

public class Tester : Node
{
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";
    private UndirectedAdjacencyListGraph<string> cgraph = null;
    private BoyerMyrvold<string> tester = null;


    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        cgraph = new UndirectedAdjacencyListGraph<string>();
        tester = new BoyerMyrvold<String>();
    }

    public void CreateCgraph(Godot.Object graph)
    {
        // cgraph.AddEdge("a","b");
        // cgraph.AddEdge("b","c");
        // cgraph.AddEdge("c","d");
        // cgraph.AddEdge("d","a");
        
        Godot.Collections.Array vertices = (Godot.Collections.Array)graph.Call("get_vertices");

        foreach (Godot.Node vertex in vertices)
        {
            if (vertex.Get("subOf") == null)
            {
                cgraph.AddVertex(vertex.Name);
            }
        }
        Godot.Collections.Array edges = (Godot.Collections.Array)graph.Call("get_edges");
        foreach (Godot.Node edge in edges)
        {
            Godot.Node vertex1 = (Godot.Node)graph.Call("get_vertex_by_name", edge.Get("from"));
            Godot.Node vertex2 = (Godot.Node)graph.Call("get_vertex_by_name", edge.Get("to"));
            if ((vertex1 != null & vertex2 != null) & (vertex1.Get("subOf") == null & vertex2.Get("subOf") == null) & (string)edge.Get("type") == "PATH")
            {
                cgraph.AddEdge(vertex1.Name, vertex2.Name);
            }
        }


    }

    public Godot.Collections.Array GetFaces(Godot.Object graph)
    {
        CreateCgraph(graph);
        GD.Print("is planar = " + tester.IsPlanar(cgraph, out var embedding));
        // GD.Print()
        tester.TryGetPlanarFaces(cgraph, out var faces);
        List<List<string>> resultFace = faces.Faces;

        Godot.Collections.Array listFaces = new Godot.Collections.Array();
        for (int i = 0; i < resultFace.Count; i++)
        {
            Godot.Collections.Array verticesFace = new Godot.Collections.Array();
            for (int j = 0; j < resultFace[i].Count; j++)
            {
                verticesFace.Add(resultFace[i][j]);
            }
            listFaces.Add(verticesFace);
        }

        return listFaces;
    }

    

//  // Called every frame. 'delta' is the elapsed time since the previous frame.
//  public override void _Process(float delta)
//  {
//      
//  }
}
