# Dapr pub/sub

In this quickstart, you'll create a publisher microservice and a subscriber microservice to demonstrate how Dapr enables a publish-subcribe pattern. The publisher will generate messages of a specific topic, while subscribers will listen for messages of specific topics. See [Why Pub-Sub](#why-pub-sub) to understand when this pattern might be a good choice for your software architecture.

For more details about this quickstart example please see the [Pub-Sub Quickstart documentation](https://docs.dapr.io/getting-started/quickstarts/pubsub-quickstart/).

Visit [this](https://docs.dapr.io/developing-applications/building-blocks/pubsub/) link for more information about Dapr and Pub-Sub.

> **Note:** This example leverages the Dapr client SDK.  If you are looking for the example using only HTTP [click here](../http).

This quickstart includes one publisher:

- Dotnet client message generator `checkout` 

And one subscriber: 
 
- Dotnet subscriber `order-processor`

### Pre-requisites

For this example, you will need:

- [Dapr CLI](https://docs.dapr.io/getting-started)
- [.NET 6 SDK](https://dotnet.microsoft.com/download)
<!-- IGNORE_LINKS -->
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
<!-- END_IGNORE -->

### Run Dotnet message subscriber with Dapr

1. Navigate to the directory and install dependencies: 

<!-- STEP
name: Install Dotnet dependencies
-->

```bash
cd ./order-processor
dotnet restore
dotnet build
```
<!-- END_STEP -->
2. Run the Dotnet subscriber app with Dapr: 

<!-- STEP
name: Run Dotnet subscriber
expected_stdout_lines:
  - "You're up and running! Both Dapr and your app logs will appear here."
  - '== APP == Subscriber received : Order { OrderId = 2 }'
  - "Exited Dapr successfully"
  - "Exited App successfully"
expected_stderr_lines:
working_dir: ./order-processor
output_match_mode: substring
background: true
sleep: 10
-->


```bash
dapr run --app-id order-processor --components-path ../components/ --app-port 7001 -- dotnet run --project .
```

<!-- END_STEP -->
### Run Dotnet message publisher with Dapr

3. Navigate to the directory and install dependencies: 

<!-- STEP
name: Install Dotnet dependencies
-->

```bash
cd ./checkout
dotnet restore
dotnet build
```
<!-- END_STEP -->
4. Run the Dotnet publisher app with Dapr: 

<!-- STEP
name: Run Dotnet publisher
expected_stdout_lines:
  - "You're up and running! Both Dapr and your app logs will appear here."
  - '== APP == Published data: Order { OrderId = 1 }'
  - '== APP == Published data: Order { OrderId = 2 }'
  - "Exited App successfully"
  - "Exited Dapr successfully"
expected_stderr_lines:
working_dir: ./checkout
output_match_mode: substring
background: true
sleep: 10
-->
    
```bash
dapr run --app-id checkout --components-path ../components/ -- dotnet run --project .
```

<!-- END_STEP -->

```bash
dapr stop --app-id order-processor
```

### Deploy apps to Azure (Azure Container Apps, Azure Service Bus)

5. Deploy to Azure for dev-test

NOTE: make sure you have Azure Dev CLI pre-reqs [here](https://github.com/Azure-Samples/todo-python-mongo-aca)

```bash
azd up
```
