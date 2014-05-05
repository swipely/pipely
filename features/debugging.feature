Feature: Pipeline Debugging Tools
  In order to spend less time diagnosing pipeline failures
  As a developer with pipely installed
  I want a CLI tool to better interact with the AWS Data Pipeline API

  Background:
    Given I have already configured AWS credentials with pipely

  Scenario: diagnosing a RubySyntaxError failure in an EMR Activity
    Given the pipeline "df-ACOEJFHJ5E61" has an instance of GenerateStoreSpenders with a FAILED status
    And I am alerted that the pipeline "df-ACOEJFHJ5E61" has failed
    When I run "pipely diagnose df-ACOEJFHJ5E61"
    Then I see a list of instances with FAILED statuses containing the instance @GenerateStoreSpenders2014-05-01T11:54:44
    And I see a list of attempts for the failing instance
    And for each attempt I see an attempt ID and a list of available log files
    And the first attempt ID is "@GenerateStoreSpenders2014-05-01T11:54:44_Attempt=1"
    And the first attempt ID lists "controller" as an available log file
    And I see suggestions for commands to diagnose the failure
    When I run "pipely logs df-ACOEJFHJ5E61_08182013CopyServersToAppDB_Attempt_1 controller"
    Then I see the contents of the controller log in standard out
    When I run "pipely inputs df-ACOEJFHJ5E61_08182013CopyServersToAppDB"
    Then I see a list of S3DataNode inputs to the CopyActivity
    And I see the first 10 lines of the first file in each input directory
    And I see the number of lines in all files combined for each input directory


  Scenario: diagnosing a failed CopyActivity
    Given the pipeline "df-ACOEJFHJ5E61" has an instance of CopyServersToAppDB with a FAILED status
    And I am alerted that the pipeline "df-ACOEJFHJ5E61" has failed
    When I run "pipely diagnose df-ACOEJFHJ5E61"
    Then I see a list of instances with FAILED statuses containing the instance @CopyServersToAppDB_2014-05-01T11:54:44
    And I see a list of attempts for the failing instance
    And for each attempt I see an attempt ID and a list of available log files
    And the first attempt ID is "df-ACOEJFHJ5E61_08182013CopyServersToAppDB_Attempt_1"
    And the first attempt ID lists "controller" as an available log file
    And I see suggestions for commands to diagnose the failure
    When I run "pipely logs df-ACOEJFHJ5E61_08182013CopyServersToAppDB_Attempt_1 controller"
    Then I see the contents of the controller log in standard out
    When I run "pipely inputs df-ACOEJFHJ5E61_08182013CopyServersToAppDB"
    Then I see a list of S3DataNode inputs to the CopyActivity
    And I see the first 10 lines of the first file in each input directory
    And I see the number of lines in all files combined for each input directory

  Scenario: diagnosing a currently running pipeline with a failed attempt

  Scenario: revising a running pipeline
    Given the I have a revised local copy of the reducer for the NormalizeServers step
    When I run "pipely upload_steps"
    Then the contents of my steps directory are uploaded to s3
    And I see feedback indicating the upload was successful
