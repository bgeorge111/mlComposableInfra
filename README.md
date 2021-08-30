# A MarkLogic composable infrastructure
## Objective
 * Quickly set up one empty / blank environment in docker for demonstrating MarkLogic capabilities with 
     - An initialized MarkLogic server
     - Empty data hub project with data hub central pre-installed 
     - Apache Nifi, Confluent Kafka and Bitami Spark with pre-installed MarkLogic connectors. 
 * Pick and choose which components are required in the infrastructure. Examples 
     - MarkLogic Server only 
     - MarkLogic Server + Kafka with MarkLogic connectors
     - MarkLogic Server + Data Hub + Spark + MarkLogic connectors
     - MarkLogic Server + Data Hub + RabbitMQ + Nifi  + MarkLogic processors
* Do not worry about installing and configuring software, port conflicts etc. Run few commands and start setting what you want to test or show ! 

## How does the target environment look like ? 

![image](https://user-images.githubusercontent.com/68338060/131232657-cbf5a078-36c6-4a0d-9c3b-9ea494342730.png)

Here, each grey box is a container. You can choose the containers you want to have. 

# Setting up the environment 

## Step 0 :: Pre-requisites 
* docker with docker-compose
* An API tool in the host - Postman, curl or SoapUI 
* If your host machine has MarkLogic server, please stop 
* Internet connection 

## Step 1 :: Create a network 
* Create a network using the below docker command. Keep the network name as demo-nw. If you want to change, refer section 'Customising the infrastructure'. <br>
 ``` docker network create demo-nw ```

## Step 2 :: Unzip the components 
* Unzip the package to a folder in the host. Going forward, we will refer it as ```root ```

## Step 3 :: Build the environment 
* Run the below docker command from the ``` root ``` folder <br>
``` docker-compose --env-file <environment file> –f <compose-file1> -f <compose-file2> -f <compose-fileN> up –d –build ``` <br>
Example: For an environment having _MarkLogic Server + Data Hub + RabbitMQ + Nifi  + MarkLogic processors_ run the following command <br>
``` docker-compose --env-file env1.env -f marklogic-compose.yml -f base-compose.yml -f rabbitmq-compose.yml -f nifi-compose.yml up -d --build ``` <br>
If all good, the ```docker-compose``` commands ends as below, depending on the compose files you choose <br>
        ```
        Creating rabbitmq       ... done <br>
        Creating spark_worker_1 ... done <br>
        Creating spark_master   ... done <br>
        Creating spark_worker_2 ... done <br>
        Creating nifi           ... done <br>
        Creating marklogic1     ... done <br>
        Creating tools          ... done <br>
        Creating zookeeper      ... done <br>
        Creating broker         ... done <br>
        Creating schema-registry ... done <br>
        Creating connect         ... done <br>
        Creating rest-proxy      ... done <br>
        Creating ksqldb-server   ... done <br>
        Creating ksqldb-cli      ... done <br>
        Creating ksql-datagen    ... done <br>
        Creating control-center  ... done <br>
        ```
### Compose Files and components

| File      | Components |
| ----------- | ----------- |
| marklogic-compose.yml | A marklogic server, not a cluster but stand alone |
| base-compose.yml | Data Hub Central, Data Hub Community edition, MLCP |
| kafka-compose.yml | All components in Confluent Kafka distribution + Marklogic Kafka Sink Connector |
| nifi-compose.yml | Apache Nifi + MarkLogic Nifi processor |
| rabbitmq-compose.yml | RabbitMQ |
| spark-compose.yml | A spark 2 cluster with a master and 2 worker nodes + MarkLogic Spark Connector. <br> Note that it is not spark 3 as marklogic spark connector is not ready for spark 3 | 

After Step 3, you are ready with the infrastructure. 

# Accessing the components in the infrastructure 

| Component      | URL  | Credentials if any | 
| ----------- | ----------- | -------------- | 
| marklogic | Admin: http://localhost:8001 | ```myadmin/myadmin``` |
| marklogic | Query Console: http://localhost:8000 | ```myadmin/myadmin``` <br> ```hc-default/MarkLogic*001``` | 
| hub central | http://localhost:28080 | ```hc-default/MarkLogic*001``` |
| nifi | https://localhost:8443/nifi | ```admin/MarkLogic*001``` | 
| rabbitmq | http://localhost:8080 | ```guest/guest``` | 
| spark master | http://localhost:38080 | None. You can navigate to spark worker screens from the master 
| Confluent control center | http://localhost:9021 | None 

At this stage, you have two choices <br>
### Choice 1 : <br> 
Set up your own project in the infrastructure. Note that at this stage, all components are configured. For example, the MarkLogic Kafka connector is installed, but not started. MarkLogic Nifi processors are installed, but no Nifi flows exists. Hub Central is accessible and data hub core components are installed, but there are not data hub projects. You can create your own projects 
 
### Choice 2 : <br> 
Alternatively, you can choose to set up projects included in the package. The rest of the documentation focusses on how to configure and run the projects included in the package. If you go with Choice 1, then rest of this documentation can be ignored. 

# Project 1: Customer Hub 
### Description 
This is a simple and common data hub project. It ingests json, csv and xml formatted customer data from three different sources - Files, Kafka and RabbitMQ over Nifi. The customer documents are mapped and curated into consumable Customer entity documents. They are also matched and merged for eliminating any duplicate customers. The spark job provided pulls the data from the FINAL database, classifies the customers into 4 clusters and writes the cluster information back from FINAL databsae. 

### Deployment 
* Go to ```projects/data-hub``` and run ```gradlew mlDeploy```

### Data Flow 
![image](https://user-images.githubusercontent.com/68338060/131282373-ad9cbed7-5984-437d-857d-75c7eff7bff5.png)


### Demonstrated Capabilities 
* Ingestion from CSV
* MarkLogic Kafka Sink Connector
* MarkLogic Nifi Processor 
* Mapping and Curation 
* Smart Mastering (Match and Merge)
* Spark Connector (Read and Write) 

 
### Starting with a Nifi Template 
* Access the Nifi portal 
* Upload the ```Customer_Flow_Template.xml``` from the ```scripts``` folder. How to load a template in Nifi is not beyond this documentation. Refer Nifi documentation for the same 
* Nifi templates do not carry sensitive information. So, provide the credentials ```guest/guest``` in both RabbitMQ processors and ```hc-default/MarkLogic*001``` in both MarkLogic processors. 
* Start the processor group. 

### Starting the Kafka Connector 
* Using your API tool (postman, soapui, curl etc), do a POST to ```http://localhost:18083/connectors``` with header ```Content-type : application/json```. In the request body, place the content from the file ```projects/data-hub/scripts/start-customer-kafka-connector.json```
* For sending a kafka message, do a POST to ```http://localhost:8082/topics/customer-topic``` with header ```Content-Type : application/vnd.kafka.json.v2+json```. In the body, place the content from the file ```projects/data-hub/scripts/kafka-customer-message.json```. If all fine, you can see two customer records in STAGING database and will harmonize

### Posting a rabbitMQ message 
* Using your API tool, do a POST to ```http://localhost:8080/api/exchanges/%2f/customer-exchange/publish``` with header ```Content-Type : application/json```. In the request body, place the content from the file ```projects/data-hub/scripts/rabbitmq-customer-message.json``` 
* As the Nifi processor is already listening to the RabbitMQ queue, one customer message will be placed in the STAGING database and harmonzied. 

### Ingesting CSVs via Hub Central 
* Login to Hub Central and take a look at the ```Customer_Flow```. The Customer CSV Files can be ingested using the Ingest FLow from the folder ```projects/data-hub/data```. 6000 Customer records will be loaded. 
* Run the ```Map_CSV_Customer``` step 

### Match and Merge
* The Match and merge rules are simple and beyond the scope of this documentation. Take a look at the rules and run those steps. 

### Submit Spark Job 
* Using your API tool a POST to ```http://localhost:36066/v1/submissions/create``` with request body from the content in ```projects/data-hub/scripts/submit-customer-clustering-spark-job.json``` 
* Look at the spark job progress in the spark master URL mentioned above. 
* Once the job is FINISHED, there will be additional documents written in FINAL database in the ```kmeans``` collection. The spark job read the documents from FINAL, performed the kmeans clustering and wrote the results back to FINAL database. 



