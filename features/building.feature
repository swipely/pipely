Feature: Building a definition from a template
  In order to keep the pipeline definition readable
  As a developer with pipely installed
  I want to dynamically generate my definitions from a template

  Background:
    I have a definition template file with configuration variables

  Scenario:
    Given I have a definition template file with configuration variables
    When I run "pipely build"
    Then a json file should be created in "definitions/"
    And I should see feedback that the file was successfully created
