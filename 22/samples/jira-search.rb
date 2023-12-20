require 'rest_client'


res = RestClient.get "https://jira.paypal.com/jira/issues/?jql=\"text ~ \"missing tax\"\""

puts res.body

