Feature: Pipeline Debugging Tools
  In order to spend less time diagnosing pipeline failures
  As a developer with pipely installed
  I want a CLI tool to better interact with the AWS Data Pipeline API

  Background:
    Given I have already configured AWS credentials with pipely

  Scenario: diagnosing a failed pipeline
    Given the pipeline "df-ACOEJFHJ5E61" has a failing CopyActivity step
    And I am alerted that the pipeline "df-ACOEJFHJ5E61" has failed
    When I run "pipely diagnose df-ACOEJFHJ5E61"
    Then I see logs from any failed attempts
    And I see sizes and previews of any inputs to the failing step
    And I see sizes and previews of any outputs to the failing step

  Scenario: revising a running pipeline
    Given the I have a revised local copy of the reducer for the NormalizeServers step
    When I run "pipely upload_steps"
    Then the contents of my steps directory are uploaded to s3
    And I see feedback indicating the upload was successful
