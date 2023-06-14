Bugsnag.configure do |config|
  config.api_key = ENV['PAIRWISE_BUGSNAG_API_KEY']
  config.auto_capture_sessions = false
end
