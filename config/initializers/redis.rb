#Heroku Redis Configuration - https://devcenter.heroku.com/articles/heroku-redis#connecting-in-ruby
$redis = Redis.new(url: ENV["REDIS_URL"])
