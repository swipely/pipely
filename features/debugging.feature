Feature: Pipeline Debugging Tools
  In order to easily debug errors in my deployed pipelines
  As a developer with pipely installed
  I want a CLI tool to interact with AWS Data Pipeline API

  Background:
    Given I have already configured AWS credentials with pipely

  Scenario: I want to investigate a known failure
    # view assets and logs
    #

  Scenario: A pipeline is failing with MismatchedArgumentsForSQLInsert
    Given a pipeline has failed with MismatchedArgumentsForSQLInsert
    And I am alerted about the failure with pipelineId df-XXXXXXXXX
    When I enter
      """
      pipely graph df-XXXXXXXXX
      """
    Then I see a graph of the pipeline highlighting the failed CopyActivity
    When I enter
      """
      pipely magically find error messages df-XXXXXXXXX
      """
    Then I see the error messages from any failed attempts on that pipeline
    When I enter ...

