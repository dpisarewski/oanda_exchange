# OandaExchange

API for OANDA exchange webservices

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oanda_exchange', :git => "git://github.com/dpisarewski/oanda_exchange.git"
```

And then execute:

```shell
bundle install
```

## Usage

1. Copy oanda_api.yml into rails config directrory

2. Insert your client_id from your OANDA subscription

3. Use Oanda.exchange(base_currency, options) method to convert currency

Examples:

```ruby
Oanda.exchange(:usd, :to => :eur)
```

```ruby
Oanda.exchange(:eur, :to => :usd, :date => Date.new(2010, 1, 1), :days => 14, :amount => 200, :interbank => 2)
```

To use exchange with ruby money(http://money.rubyforge.org/) add into your application configuration:

```ruby
Money.default_bank = OandaBank.new
```

To obtain a hash with all supported currencies use

```ruby
Oanda.currencies
```

To avoid API calls to OANDA in test environment you can use predefined stubs:

```ruby
OandaExchange::Stubs.stub!(options)
```

options can be :currencies and :rates.
:currencies should be a hash that is returned by Oanda.currencies.
Default value for :currencies is `{"USD" => "US Dollar", "EUR" => "Euro"}`

:rates      should be a hash that is used for currency conversion by Oanda.exchange.
Default value for rates is `{"USD" => 1, "others" => 1.5}`

For example

```ruby
OandaExchange::Stubs.stub! :currencies => {"USD" => "US Dollar",
                                           "CAD" => "Canadian Dollar",
                                           "RUB" => "Russian Rouble"},
                           :rates =>      {"CAD" => 0.7, "RUB" => 0.03}
```
