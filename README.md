# Markr-api - README
Ruby 2.6.5, Rails 6.0.2

## To run this project locally
### First time set up
From the project directory, run:
- `docker-compose build` (This will take a couple of minutes)
- `docker-compose run web rails db:create`
- `docker-compose run web rails db:migrate`

### Then...
- To run tests: `docker-compose run web bundle exec rspec`
- To run server (detach will run in background): `docker-compose up [--detach]`
Check for the "Yay! You’re on Rails!" page on http://localhost:3000

## Project requirements
### Import
- Recieve a POST request to `/import` with an xml body
- Check content-type header (`text/xml+markr`) valid and xml body valid
- Parse and save the `mcq-test-result` records (using the summary-marks and ignoring individual answers)
- Expect duplicates within and between imports - record should be updated to the higher of the value

### Aggregate
- Receive a GET request to `/results/:test-id/aggregate`
- For that test, calculate and return as json:
  - `mean` - the mean of the awarded marks
  - `count` - the number of students who took the test
  - `p25`, `p50`, `p75` - the 25th percentile, median, and 75th percentile scores
- Scores should be given as percentages to one decimal

## Assumptions and summary
### Validations
- Test results are saved to the test_results table
- I rely on Rails active record validations to validate each record being imported
- I save student names in addition to the other data and made these required fields
- Therefore for a record to be valid it must have: `test_id`, `student_number`, `marks_available`, `marks_obtained`, as well as `student_first_name` and `student_last_name`
- `test_id` and `student_number` are saved as strings to give the most flexibility (for example student 'numbers' are often alpha-numeric).

### Rejecting records
- "it's important that you reject the _entire_ document with an appropriate HTTP error" 
- I interpreted this as meaning the _entire batch_ of tests being imported should be rejected (if some are saved and some not, you wouldn't expect an HTTP error status)
- This is done by wrapping the `save!` in a transaction block, so that if one record is invalid it will raise an error. This error is caught and returned with a status of 422.
- This will only give information for the first invalid record being imported as it aborts the method

### Updating records
- Using `TestRecord.find_or_initialize_by` takes this into account duplicates within an import as well as already saved records.
- I wasn't sure if available marks could change as well, either between students' results for a particular test (e.g. are there students that do different sections for a different available total?) or in duplicate scans of an individual students test (e.g. if there is a marks obtained error, could there be a marks available error?)
- I update both marks obtained and marks available to the highest received to account for that

### Aggregating test results
- I moved the calculation of summary metrics into a plain Ruby object, which is initialised by an array of scores.
- The `#metrics` method returns a hash aligning to the form expected in the response
- There was a small mismatch between the values that were specifically requested in the text and those in the example json. I chose to return all values in the json example (those requested with the addition of `stdev` `min` and `max`).
- Percentile is calculated using the Nearest rank method, where `rank = ⌈(P / 100.0 * n)⌉`
- Due to not knowing if marks available was an unchanging trait for a test_id, I calculate the marks as percentage for each individual record.

### Other
- There is a comment about persistent storage. I interpreted this to just mean saved to a database. I'm not sure if it meant something more.

## Potential improvements
- In hindsight, there might be a better name for `test_results` that makes it clear it's not related to the project test suite.
- Despite abstracting some logic into a Ruby class, the test results controller is still quite heavy. At Discolabs we have been using the interactor gem to perform any business logic, leaving controllers very light.
- As mentioned, rejecting an entire import batch only gives info about the first record that was found to be invalid. It might be better to validate the entire import and return information on all invalid records.
- There is no model representing the test itself.
