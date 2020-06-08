
### Parse data using an ingest pipeline
When you use Elasticsearch for output, you can configure Filebeat to use an ingest pipeline to pre-process documents before the actual indexing takes place in Elasticsearch. 

After defining the pipeline in Elasticsearch, you simply configure Filebeat to use the pipeline. To configure Filebeat, you specify the pipeline ID in the parameters option under elasticsearch in the filebeat.yml file:

### pipeline.json
For example, let’s say that you’ve defined the following pipeline in a file named pipeline.json:
```
{
    "description": "Test pipeline",
    "processors": [
        {
            "lowercase": {
                "field": "agent.name"
            }
        }
    ]
}
```

### PUT pipeline.json to elasticsearch
To add the pipeline in Elasticsearch, you would run:
$ curl -H 'Content-Type: application/json' -XPUT 'http://localhost:9200/_ingest/pipeline/test-pipeline' -d@pipeline.json

### Then in the filebeat.yml file, you would specify:
```
output.elasticsearch:
  hosts: ["localhost:9200"]
  pipeline: "test-pipeline"
```

### Result
When you run Filebeat, the value of agent.name is converted to lowercase before indexing.



