# OandaExchange

API for OANDA exchange webservices

## Installation

Add this line to your application's Gemfile:

    gem 'oanda_exchange', :git => "git@github.com:arvatoSystemsNA/oanda_exchange.git"

And then execute:

    $ bundle

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

To use exchange with ruby money(http://money.rubyforge.org/) add into your application configuration:

```ruby
Money.default_bank = OandaBank.new
```
