require 'redis'
require 'yaml'

redis_config = YAML.load_file(Rails.root.join('config', 'redis.yml'))[Rails.env]

$redis = Redis.new(
  host: redis_config['host'],
  port: redis_config['port'],
  username: redis_config['username'],
  password: redis_config['password']
)
