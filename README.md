# Reservation API

A simple reservation API created as a timeboxed [Hometime.io](https://hometime.io) take home [test project](SPEC.md).

Sticking strickly to the timebox requested, I've completed what I can within it.

* I wanted to add an "AuditLogger" for API request transactions, but didn't have the time.
* Needs automated testing. Really should have some basic tests.
* More code improvements, and thoughfulness with more time.
* More specific "Call Outs" listed below.
* Etc...

## Set up:

Rails environment:

* [Set up Ruby on Rails](https://guides.rubyonrails.org/getting_started.html#creating-a-new-rails-project-installing-rails)
* `ruby '2.7.3'`
* `Rails '6.1.4'`

Install this application:

* `> bundle install`
* `> rails db:migrate`

Redis:

* `> brew insall redis`
* Find it's path, mine is `/usr/local/etc/redis.conf`
* Update your path in the `Procfile.dev` for the redis worker.

Run this application:

* `> foreman start -f Procfile.dev`

Sidekiq Dashboard:

* `http://localhost:3000/sidekiq`

Maintain this application:

* `> rubocop`
* `> rails test` (not yet implemented)

Generate / View Docs:

* `> gem install yard`
* `> yard` to generate docs
* `> yard server` to view the docs locally
* `http://0.0.0.0:8808` (on my localhost)

Alerting:

* I'm using **Rollbar** for exception tracking. 

* This 3rd party serves as a central hub where we can filter by 
severity level, exception type, or error string. We can then pop off an email, 
Slack, SMS text, etc.. alerts based upon our desire to stay on top 
of things.

* I've hard coded the `access_token` within the `rollbar.rb` initializer. 
Normally would NOT do this, instead I'd add that to an environment file (`.env`) 
outside of the git repo.

## Introducing a 3rd Payload:

To introduce more than two payloads, from different partners...

* Add a new model that inherits from the Reservation model.
* Name this model the same and/or similar to the new partner.
* Add a new `config/partners/schemas/<partner.json>` file.
* Create required helper function(s) as needed.

This is also where atomic level validation occurs and can easily
be extended beyond the simple cases I've covered to harden what should,
and should not be accepted from individual 3rd party API requests.

## Call Outs:

#### #1

For the purposes of this exercise, I will be defining the following
payloads as:

* payload_1 = Airbnb.com
* payload_2 = Bookings.com

#### #2

Associations.

I'm assuming only one Guest record per Reservation for this project.

Typically you can add more guests to a reservation system but that is
usually optional (in my experience). So I'm going with this approach
since nothing is directly called out within the specification.

#### #3

API endpoint. 

* Is open to the public (very bad).

* Should be an authenticated / verified on each request.

#### #4

Payload 2.

`localized_description` found in
payload_2 is not found within payload_1. 

For this exercise, I will be ignoring this field as we can handle 
localization differently.


#### #5

Payload_1


```
"payout_price": "4200.00", 
"security_price": "500", 
"total_price": "4700.00"
```

Payload_2

```
"total_paid_amount_accurate": "4300.00"
"listing_security_price_accurate": "500.00", 
"expected_payout_amount": "3800.00", 
```

These appear to be calculations, though I won't be calculating 
as nothing was called out within the specification for this.

