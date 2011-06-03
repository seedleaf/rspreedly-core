#RSpreedlyCore
A ruby wrapper for [SpreedlyCore](https://spreedlycore.com/) API.

[SpreedlyCore](https://spreedlycore.com/) is a great service that allows for safe storage of credit cards making transactions safe, easy and flexible. Check it out!

#Installation

Until released and published on rubygems the best is to install with bundler and point to this repository. In the Gemfile of your project:  

    gem 'rspreedly-core', :git => 'git://github.com/seedleaf/rspreedly-core'

And of course: 
  
    bundle install

#Usage

##Configuration

Configure your API login and secret for your account:

    RSpreedlyCore::Config.setup do |config|
      config[:api_login] = "your api_login"
      config[:api_secret] = "your api_secret"
    end

##PaymentMethods

Most likely you will want to be storing credit cards with spreedly-core. If so, the first step is to post with transparent redirect to rspreedly-core in order to get a token as explained [here](https://spreedlycore.com/manual/quickstart). If successful you should be returned a token with which you can validate the credit card:

    payment_method = RSpreedlyCore::PaymentMethod.validate(token)

One can easily transfer the attributes of this payment_method to a an ActiveRecord model is desired for local storage. Note that spreedly-core already returns a sanitized version without sensitive data. 

    CreditCard.new(payment_method.attributes)

Included in the attributes are any errors which you can utilize directly or easily convert to your local model. 

The payment_method or token can be used for retaining and redacting:

     payment_method.retain
     RSpreedlyCore::PaymentMethod.redact(token)

Note that these return instances of RSpreedlyCore::Transaction which includes important data including the success of the action: 

     transaction = RSpreedlyCore::PaymentMethod.retain(token)
     transaction.success?

##Transactions

TODO

##Gateways

TODO

# Contributing to rspreedly-core

##Running Specs

To run the specs you will need to

    bundle install
    cp spec/credentials.yml.example spec/credentials.yml
    rake spec

If you want to run or add integration specs that actually hit the api then you will need to add some real credentials to spec/credentials.yml. To run the integration specs:

    rake spec:integration

##Adding new features
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

#Copyright

Copyright (c) 2011 Entryway Pair. See LICENSE.txt for
further details.