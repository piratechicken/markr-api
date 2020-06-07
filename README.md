# Markr-api - README
Ruby 2.6.5, Rails 6.0.2

## To run this project locally
### First time set up
From the project directory, run:
- `docker-compose build` (This will take a couple of minutes)
- `docker-compose up [--detach]`
- `docker-compose run web rails db:create`
- `docker-compose run web rails db:migrate`
Check for the "Yay! You’re on Rails!" page on http://localhost:3000

### To run subsequently
From the project directory, run:
- `docker-compose up [--detach]`

## Project requirements
### Import
- Recieve a POST request to `/import` with an xml body
- Check content-type header (`text/xml+markr`) valid and xml body valid
- Parse and save the results
- Expect duplicates - record should be updated to the higher of the value

### Aggregate
- Receive a GET request to `/results/:test-id/aggregate`
- For that test, calculate and return as json:
  - `mean` - the mean of the awarded marks
  - `count` - the number of students who took the test
  - `p25`, `p50`, `p75` - the 25th percentile, median, and 75th percentile scores
