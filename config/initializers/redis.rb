require 'redis'

puts "REDIS REDIS REDIS REDIS REDIS REDIS REDIS REDIS REDIS REDIS REDIS REDIS REDIS REDIS REDIS REDIS REDIS REDIS REDIS REDIS REDIS REDIS"
puts "Host: #{ENV['REDIS_HOST']}"
puts "Port: #{ENV['REDIS_PORT']}"
puts "Username: #{ENV['REDIS_USERNAME']}"
puts "Password: #{ENV['REDIS_PASSWORD']}"

$redis = Redis.new(
  host: ENV['REDIS_HOST'],
  port: ENV['REDIS_PORT'].to_i,
  username: ENV['REDIS_USERNAME'],
  password: ENV['REDIS_PASSWORD']
)
