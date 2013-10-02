pipely
======
[![Gem Version](https://badge.fury.io/rb/pipely.png)](http://badge.fury.io/rb/pipely) [![Build Status](https://travis-ci.org/swipely/pipely.png?branch=master)](https://travis-ci.org/swipely/pipely) [![Code Climate](https://codeclimate.com/repos/524b941156b1025b6c08a96a/badges/c0ad2bbec610f1d0f0f7/gpa.png)](https://codeclimate.com/repos/524b941156b1025b6c08a96a/feed)

Visualize pipeline definitions for AWS Data Pipeline

"AWS Data Pipeline is a web service that you can use to automate the movement and transformation of data. With AWS Data Pipeline, you can define data-driven workflows, so that tasks can be dependent on the successful completion of previous tasks."

http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/what-is-datapipeline.html


## Install

(First install [GraphViz](http://www.graphviz.org) if it is not already installed.)

Into Gemfile from rubygems.org:

    gem 'pipely'

Into environment gems from rubygems.org:

    gem install pipely


## Usage

(If you used the Gemfile install, prefix the below commands with `bundle exec`.)

### Command-line Interface

To render a JSON pipeline definition as a PNG graph visualization:

    pipely definition.json

To specify the output path for PNG files:

    pipely -o path/to/graph/pngs definition.json

### Rake Tasks

Coming soon.
