require 'rspec/mocks/standalone'

module OandaExchange::Stubs

  DEFAULT_CURRENCIES  = {"USD" => "US Dollar", "EUR" => "Euro"}
  DEFAULT_RATES       = {"USD" => 1, "other" => 1.5}

  def self.stub!(options = {})
    rates = options[:rates] || DEFAULT_RATES
    Oanda.stub!(:exchange) do |cur, opts|
      BigDecimal.new((opts[:amount] || 0).to_s, 5) * (rates[cur] || rates["other"] || 1)
    end
    Oanda.stub!(:currencies).and_return(options[:currencies] || DEFAULT_CURRENCIES)
  end
end