require 'rspec/mocks/standalone'

module OandaExchange::Stubs

  def self.stub!
    Oanda.stub!(:exchange) do |cur, opts|
      if cur != "USD"
        BigDecimal.new((opts[:amount] || 0).to_s) * 1.5
      else
        BigDecimal.new((opts[:amount] || 0).to_s)
      end
    end
    Oanda.stub!(:currencies).and_return("USD" => "US Dollar", "EUR" => "Euro")
  end
end