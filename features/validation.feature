Feature: Pipeline Debugging Tools
  In order to easily debug errors in my deployed pipelines
  As a developer with pipely installed
  I want a CLI tool to interact with AWS Data Pipeline API

  Background:
    Given I have already configured AWS credentials with pipely

  Scenario: I want to know what pipelines are deployed
    When I run
      """
      pipely list
      """
    Then I should see a list of deployed pipelines

  Scenario: I want to know if my deployed pipeline has completed yet

  Scenario: I want to verify the health of my pipelines

