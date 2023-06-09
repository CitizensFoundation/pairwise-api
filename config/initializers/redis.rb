require 'redis'

$redis = Redis.new(
  host: ENV['REDIS_HOST'],
  port: ENV['REDIS_PORT'].to_i,
  username: ENV['REDIS_USERNAME'],
  password: ENV['REDIS_PASSWORD']
)
