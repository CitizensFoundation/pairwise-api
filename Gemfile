source "https://rubygems.org"

ruby '3.1.2'

gem 'protected_attributes_continued'
gem "memoist"
gem "rtiss_acts_as_versioned"
gem "delayed_job_active_record"
gem "puma"
gem "passenger"
gem "iconv"
gem 'bootsnap', require: false
gem "bugsnag", "~> 5.5.0"
gem "rake", ">= 13.0.6"
gem "rdoc", "~> 3.12"
gem "rails", "7.0.4"
gem "sprockets-rails"
gem "libxml-ruby", "2.9.0", :require => "libxml"
gem "ambethia-smtp-tls", "1.1.2", :require => "smtp-tls"
gem "paperclip", "2.3.1"
gem "mime-types", "1.16",
    :require => "mime/types"
gem "xml-simple", "1.1.9",
    :require     => "xmlsimple"
#gem "yfactorial-utility_scopes", "0.2.3",
#    :require     => "utility_scopes"
gem "formtastic", "4.0.0"
gem "inherited_resources",  "1.13.1"
gem "has_scope",  "0.8.0"
gem "responders",  "3.0.1"
#gem "thoughtbot-clearance", "0.8.2",
#    :require     => "clearance"
gem "clearance"
gem "fastercsv", "1.5.1", :platforms => :ruby_18
gem "delayed_job", "4.1.10"
gem "redis", "~> 4.7.1"
gem "test-unit", "1.2.3"
gem "highcharts-rails"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "jbuilder"
gem "sendgrid", "1.2.4"
gem "json_pure", "2.6.2"
#gem "rubaidh-google_analytics", "1.1.4", :require => "rubaidh/google_analytics"
gem 'mysql2', '0.5.4'

group :cucumber do
  gem 'cucumber', '1.1.0'
  gem 'cucumber-rails', '0.3.2'
  gem 'webrat', "0.5.3"
 # gem 'fakeweb', '1.2.5'
end

group :test do
  gem "rspec", "3.11.0"
  gem "rspec-rails", "5.1.2"
  gem "shoulda", "~>2.10.1"
  gem "jtrupiano-timecop", "0.2.1",
    :require     => "timecop"
  gem "fakeweb", "1.2.5"
  gem "jferris-mocha", "0.9.5.0.1241126838",
    :require     => "mocha"
end

group :test, :cucumber do
  gem 'factory_girl', '1.2.3'
  gem 'mock_redis', '0.4.1'
end
gem 'ey_config'
gem "newrelic_rpm"
