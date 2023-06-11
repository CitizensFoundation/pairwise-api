require 'redis'
require 'yaml'

redis_yml = Rails.root.join('config', 'redis.yml')
REDIS_CONFIG = YAML::load(ERB.new(IO.read(redis_yml)).result)[Rails.env]

puts "REDIS CONFIGURATION"
puts "Host: #{REDIS_CONFIG['host']}"
puts "Port: #{REDIS_CONFIG['port']}"
puts "Username: #{REDIS_CONFIG['username']}"
#puts "Password: #{REDIS_CONFIG['password']}"
puts "SSL: #{REDIS_CONFIG['ssl']}"

$redis = Redis.new(
  host: REDIS_CONFIG['host'],
  port: REDIS_CONFIG['port'],
  username: REDIS_CONFIG['username'],
  password: REDIS_CONFIG['password'],
  ssl: REDIS_CONFIG['ssl']
)
