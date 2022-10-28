# rake db:seed
# load the API user for AOI dev environment

u = User.new(:email => ENV['PAIRWISE_USERNAME'], :password => ENV["PAIRWISE_PASSWORD"])
u.save(:validate => false)
