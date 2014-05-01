Feature: Pipeline Reporting
  In order to quickly understand the state of my deployed pipelines
  As a developer with pipely installed
  I want a CLI tool to better interact with the AWS Data Pipeline API

  Background:
    Given I have already configured AWS credentials with pipely

  Scenario: I want to see the progress/state of a running pipeline
    When I run "pipely graph df-JGEOWFLA34IJ1"
    Then I should see a png graphing the pipeline with step states

  Scenario: I want to know what pipelines are deployed
    When I run "pipely list"
    Then I should see a list of deployed pipelines

  Scenario: I want to know if the pipeline df-JGEOWFLA34IJ1 has completed yet
    When I run "pipely status df-JGEOWFLA34IJ1"
    Then I should see an indication of whether the pipeline is running

  Scenario: I want to know how the pipeline "df-JGEOWFLA34IJ1" has performed recently
    When I run "pipely history df-JGEOWFLA34IJ1"
    Then I should see a list of recent runs with start and end times

  Scenario: I want to know step-level performance for a particular run of the pipeline "df-JGEOWFLA34IJ1"
    When I run "pipely performance df-JGEOWFLA34IJ1"
    Then I should see a list of steps and attempts for that pipeline run with start and end times

