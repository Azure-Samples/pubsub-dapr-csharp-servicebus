using System;
using Dapr.Client;
using System.Text.Json.Serialization;
using System.Threading.Tasks;


while (true)
{
    for (int i = 1; i <= 20; i++)
    {
        var order = new Order(i);
        using var client = new DaprClientBuilder().Build();

        // Publish an event/message using Dapr PubSub
        await client.PublishEventAsync("orderpubsub", "orders", order);
        Console.WriteLine("Published data: " + order);

        await Task.Delay(TimeSpan.FromSeconds(1));
    }
    await Task.Delay(TimeSpan.FromSeconds(10));
}

public record Order([property: JsonPropertyName("orderId")] int OrderId);
