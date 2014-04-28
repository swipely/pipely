pipely
======
[![Gem Version](https://badge.fury.io/rb/pipely.png)](http://badge.fury.io/rb/pipely) [![Build Status](https://travis-ci.org/swipely/pipely.png?branch=master)](https://travis-ci.org/swipely/pipely) [![Code Climate](https://codeclimate.com/repos/524b941156b1025b6c08a96a/badges/c0ad2bbec610f1d0f0f7/gpa.png)](https://codeclimate.com/repos/524b941156b1025b6c08a96a/feed)

Pipely is a tool to help you better understand and interact with Amazon's Data Pipeline. 

"AWS Data Pipeline is a web service that you can use to automate the movement and transformation of data. With AWS Data Pipeline, you can define data-driven workflows, so that tasks can be dependent on the successful completion of previous tasks."

http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/what-is-datapipeline.html

### Install

(First install [GraphViz](http://www.graphviz.org) if it is not already installed.)

Into Gemfile from rubygems.org:

    gem 'pipely'

Into environment gems from rubygems.org:

    gem install pipely

### What Pipely can help with

* Abstractions and helpers for a cleaner definition template file
* Building, validating, uploading steps, and deploying the pipeline definition
* Representing a static definition graphically
* Tracking the state of a live pipeline and alerting on failure
* Diagnosing failures with easy access to logs and outputs for a failed step
* Reporting on elapsed times for steps and understanding performance bottlenecks

### The Pipely Shell

The easiest way to use most pipely features is through an interactive shell. From the root directory of your pipeline repo, use `pipely` (or `bundle exec pipely` if you used the Gemfile install). 

    $ pipely
    pipely (current_pipeline_repo) > 
    
From here, you can use the following commands during development:

`definition`: Render the template file at templates/pipeline.json.erb to a json definition.  
`deploy`: Deletes the existing pipeline deployed with these credentials, uploads steps, and deploys the new definition.  Will prompt you to confirm the deploy.  
`graph_definition`: Based on the current json file in `definitions/`, generates a Graphviz png.  
`graph [PIPELINE_ID]`: Graphs the given pipeline id with status information for each step. Given no arguments, graphs the current active pipeline.  
`upload_steps`: Copies files in the steps directory to s3. Does not alter the pipeline schedule and can be done during a pipeline run.  
`active`: Prints the id of the current active pipeline.  
`logs COMPONENT_ID`: Prints log paths for a given component.  
`inputs COMPONENT_ID`: Prints asset paths to the inputs of a given component.  
`outputs COMPONENT_ID`: Prints asset paths to the output of a given component.  
`watch`: Prints a URL that hosts a png graph of the current active pipeline and it's steps. Launches a process to poll AWS, update the png, and alert you on any failure. Hangs the pipely shell.  

### Configuration

Pipely uses the aws-sdk gem to communicate with the AWS Data Pipeline API. To use pipely, you'll need to save a `.pipely` YAML config file to your home directory. It follows the following format:

```
:access_key_id: VNEORWUJEKWFEIWO
:secret_access_key: JFIOEWN+jf3JFlFCVONQlNEFu+FE+
:region: 'us-east-1'
```

### Rake Tasks

Coming soon.

    rake definition        # Graphs the full pipeline definition using Graphviz
    rake deploy            # Deploy pipeline
    rake graph             # Graphs the full pipeline definition using Graphviz
    rake upload_steps      # Upload Data Pipeline steps to S3

### Command-line Interface

(If you used the Gemfile install, prefix the below commands with `bundle exec`.)

To render a JSON pipeline definition as a PNG graph visualization:

    pipely definition.json

To specify the output path for PNG files:

    pipely -o path/to/graph/pngs definition.json

