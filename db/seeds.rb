# rake db:seed
# load the API user for AOI dev environment

u = User.new(:email => ENV['PAIRWISE_API_USER'], :password => ENV["PAIRWISE_API_PASSWORD"])
u.save(:validate => false)
