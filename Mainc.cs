using Godot;
using System;
using GraphPlanarityTesting.Graphs.DataStructures;

public class Mainc : Node
{
    // Declare member variables here. Examples:
    // private int a = 2;
    // private string b = "text";

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        GD.Print(true);
        UndirectedAdjacencyListGraph<string> graph = new UndirectedAdjacencyListGraph<string>();

    }

//  // Called every frame. 'delta' is the elapsed time since the previous frame.
//  public override void _Process(float delta)
//  {
//      
//  }
}
