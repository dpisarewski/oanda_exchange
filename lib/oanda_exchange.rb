require "oanda_exchange/config"
require "oanda_exchange/oanda"
require "oanda_exchange/oanda_bank"

if defined? RSpec and Oanda::Config.env == "test"
  require "oanda_exchange/stubs"
end