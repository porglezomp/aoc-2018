using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

class MarbleGame {
    static void Main() {
        var input = Console.ReadLine();
        var regex = new Regex(@"(\d+) players; last marble is worth (\d+) points");
        var groups = regex.Match(input).Groups;
        var numPlayers = uint.Parse(groups[1].Value);
        var lastWorth = uint.Parse(groups[2].Value);
        Console.WriteLine(PlayGame(numPlayers, lastWorth));
        Console.WriteLine(PlayGame(numPlayers, lastWorth * 100));
    }

    public static uint PlayGame(uint numPlayers, uint lastWorth) {
        var playerScores = new uint[numPlayers];
        var marbles = new LinkedList<uint>();
        marbles.AddLast(0);
        CircularListNode<uint> currentMarble = marbles.First;
        for (uint marble = 1; marble <= lastWorth; ++marble) {
            uint player = (marble - 1) % numPlayers;
            if (marble % 23 == 0) {
                playerScores[player] += marble;
                currentMarble = currentMarble.Retreat(6);
                var previousMarble = currentMarble.Previous;
                playerScores[player] += previousMarble.Value;
                marbles.Remove(previousMarble.Node);
            } else {
                currentMarble = marbles.AddAfter(currentMarble.Next.Node, marble);
            }
        }
        return playerScores.Max();
    }
}

struct CircularListNode<T> {
    public T Value => Node.Value;
    public CircularListNode<T> Next => Node.Next ?? Node.List.First;
    public CircularListNode<T> Previous => Node.Previous ?? Node.List.Last;
    public LinkedListNode<T> Node { get; }
    public CircularListNode(LinkedListNode<T> node) => Node = node;

    public static implicit operator CircularListNode<T>(LinkedListNode<T> node)
        => new CircularListNode<T>(node);

    public CircularListNode<T> Retreat(uint steps) {
        var node = this;
        for (uint i = 0; i < steps; ++i) {
            node = node.Previous;
        }
        return node;
    }
}
