require "money"

class OandaBank < Money::Bank::Base

  def exchange_with(from, to_currency)
    Oanda.exchange(from.currency.to_s, :to => to_currency.to_s, :amount => from)
  end

end