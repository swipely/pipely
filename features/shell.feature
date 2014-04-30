Feature: Shell
  In order to easily interact with AWS Data Pipeline
  As a developer with pipely installed
  I want an interactive prompt specific to the pipeline I am working on

  Scenario: Start the pipely shell
    Given I start the pipely app with a pipeline id
    Then I should see a welcome message

  Scenario: Start the pipely shell
    Given I start the pipely app
    Then I should see a welcome message
    And I should see a help message

  Scenario: Entering text
    Given I start the pipely app with a pipeline id
    When I enter "foo"
    Then I should see
    """
    foo
    """

  Scenario: Closing the shell
    Given I start the pipely app with a pipeline id
    When I enter a close command
    Then the shell should terminate
