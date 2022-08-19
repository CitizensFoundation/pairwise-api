# rake db:seed
# load the API user for AOI dev environment

u = User.new(:email => "pairwisetest@dkapadia.com", :password => "wheatthins")
u.save(:validate => false)
