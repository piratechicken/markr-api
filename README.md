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