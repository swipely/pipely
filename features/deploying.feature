Feature: Deploying a pipeline to AWS
  In order to test and run my code on real AWS machines
  As a developer with pipely installed
  I want to deploy my pipeline definition

  Background:
    Given I have already configured AWS credentials with pipely

  Scenario: Deploying a pipeline
    Given I have a valid definition json file in "definitions/"
    And I have a pipeline of the same name deployed to AWS
    When I run "pipely deploy"
    Then the contents of my steps directory are uploaded to s3
    And I see feedback indicating the upload was successful
    And I see feedback that the existing pipeline was deleted
    And I see feedback that a new pipeline was deployed and activated
