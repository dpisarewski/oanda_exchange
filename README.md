# OandaExchangeApi

API for OANDA exchange webservices

## Installation

Add this line to your application's Gemfile:

    gem 'oanda_exchange_api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oanda_exchange_api

## Usage

1. Copy oanda_api.yml into rails config directrory

2. Insert your client_id from your OANDA subscription

3. Use Oanda.exchange(base_currency, options) method to convert currency

Examples:

```ruby
  Oanda.exchange(:usd, :to => :eur)
```

```ruby
  Oanda.exchange(:eur, :to => :usd, :date => Date.new(2010, 1, 1), :days => 14, :amount => 200)
```
