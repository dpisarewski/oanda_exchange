require "rest-client"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/enumerable"
require "active_support/core_ext/big_decimal"
require "active_support/core_ext/hash/conversions"

class Oanda

  attr_accessor :base_currency, :quote_currency, :date, :days, :amount, :response, :resp_hash, :interbank

  def self.exchange(base_currency, options = {})
    new.exchange(base_currency, options)
  end

  def self.currencies
    new.currencies
  end

  def exchange(base_currency, options = {})
    raise Exception.new("no base currency specified")   if base_currency.blank?
    raise Exception.new("no quote currency specified")  if options[:to].blank?
    self.base_currency      = base_currency.to_s.upcase
    self.quote_currency     = options[:to].to_s.upcase
    self.date               = options[:date]      || Date.today
    self.days               = options[:days]      || 1
    self.amount             = options[:amount]    || 1
    self.interbank          = options[:interbank] || 0
    self.response           = exchange_request(build_request)
    self.resp_hash          = Hash.from_xml response
    average_rate    = calculate_average_rate
    self.interbank  = average_rate * interbank.to_f / 100
    base_currency == quote_currency ? average_rate : average_rate + interbank
  end

  def currencies
    self.response           = currencies_request
    self.resp_hash          = Hash.from_xml response
    extract_currencies
  end


  def api_request(request_string, &block)
    OandaExchange::Config.logger.debug "OANDA API: request body\n#{request_string}"
    resp = yield request_string
    OandaExchange::Config.logger.debug "OANDA API: response #{resp.code}\n#{resp.body}"
    raise Exception.new("Unexpected response code from OANDA API. See log entries with debug level to get more information.") unless resp.code == 200
    resp.body
  end

  def exchange_request(request_string)
    api_request request_string do
      OandaExchange::Config.logger.debug "OANDA API: request \n#{config[:exchange_service_url]}"
      OandaExchange::Config.logger.info "OANDA API: requesting #{base_currency} conversion into #{quote_currency}"
      RestClient.get "#{config[:exchange_service_url]}", :params => {:fxmlrequest => request_string}
    end
  end

  def currencies_request
    api_request "" do
      OandaExchange::Config.logger.debug "OANDA API: request \n#{config[:currencies_url]}"
      RestClient.get "#{config[:currencies_url]}"
    end
  end


  protected

  def extract_currencies
    resp_hash['CURRENCYCODES']['CURRENCY'].inject({}) do |hash, node|
      hash.merge node['CODE'] => node['COUNTRY']
    end
  end

  def calculate_average_rate
    exchange_rates = extract_exchange_rates
    (exchange_rates.sum / exchange_rates.size).round(5) rescue BigDecimal.new('0', 5)
  end

  def extract_exchange_rates
    extract_rates.reject{|ask, bid| ask == "na" or bid == "na"}.map do |ask, bid|
      ((BigDecimal.new(ask, 5) + BigDecimal.new(bid, 5)) / 2).round(5)
    end
  end

  def extract_rates
    resp_hash["CONVERSION"].map{|hash| [hash['ASK'], hash['BID']]}
  end

  def build_request
    {:convert =>
      {
        :date       => date.strftime('%m/%d/%Y'),
        :client_id  => config[:client_id],
        :exch       => base_currency,
        :expr       => quote_currency,
        :nprices    => days,
        :amount     => amount
      }
    }.to_xml
  end

  def config
    OandaExchange::Config.get
  end

end