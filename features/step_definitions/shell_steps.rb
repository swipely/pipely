require 'stringio'

Given(/^I start the pipely app$/) do
  init_shell
end

Given(/^I start the pipely app with a pipeline id$/) do
  init_shell_with_id
end

Then(/^I should see a welcome message$/) do
  expect_output("Pipely Shell")
end

Then(/^I should see a help message$/) do
  expect_output("You can specify a pipeline id with '--id [pipeline_id'")
end

When(/^I enter a close command$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the shell should terminate$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I enter "(.*?)"$/) do |command|
  @app.interpret(command)
end

Then(/^I should see$/) do |string|
  expect_output(string)
end

def expect_output(output)
  @io.rewind
  @io.read.split("\n").should include(output)
end

def init_shell
  @io  = StringIO.new
  @app = Pipely::Shell.new([], @io)
end

def init_shell_with_id
  @pipeline_id = 'df-FMKEFEWHIK37LF'

  argv = "--id #{@pipeline_id}".split(/\s+/)

  @io = StringIO.new
  @app = Pipely::Shell.new(argv, @io)
end
