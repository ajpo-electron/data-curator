Feature: Open a Semi-colon separated value file
  As a Data Packager
  I want to open a semi-colon separated value file
  So that I can describe, validate and package the data

  The Open Semi-colon separated value file command can be invoked using the menu command

  The data may be stored in a ".csv" file

  Use the default values in the [CSV Dialect specification](http://frictionlessdata.io/specs/csv-dialect/#specification) but with 'delimiter' = ';' to open the file and separate the values into the correct columns.

  Desirable features include:
  - If the active tab is empty, when the file is opened, insert the file contents into the empty table
  - "Guess Column Properties" on open

  Scenario: Open an existing semi-colon separated value file
    Given I have opened Data Curator
    When I invoke the "Open semi-colon Separated" command
    Then a prompt, requesting the 'filename' and location is shown
    And only files ending with a ".csv" can be selected
    And the selected 'filename' is opened in a new data tab to the right of any other open data tabs
    And set the Tab name to the 'filename'
    And set the CSV Dialect in the Table Properties to "Semi-colon Separated"
    And "Fix Ragged Rows"
    And "Freeze Header Row"
