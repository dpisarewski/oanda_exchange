require "nokogiri"
require "rest-client"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/enumerable"
require "active_support/core_ext/big_decimal"

class Oanda

  attr_accessor :base_currency, :quote_currency, :date, :days, :amount, :xml_doc, :response

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
    self.date               = options[:date] || Date.today
    self.days               = options[:days] || 1
    self.amount             = options[:amount] || 1
    self.response           = exchange_request(build_request)
    self.xml_doc            = Nokogiri::XML(response)
    calculate_average_rate
  end

  def currencies
    self.response           = currencies_request
    self.xml_doc            = Nokogiri::XML(response)
    extract_currencies
  end


  def api_request(request_string, &block)
    OandaExchange::Config.logger.info "OANDA API: requesting #{base_currency} conversion into #{quote_currency}"
    OandaExchange::Config.logger.debug "OANDA API: request body\n#{request_string}"
    resp = yield request_string
    OandaExchange::Config.logger.debug "OANDA API: response #{resp.code}\n#{resp.body}"
    raise Exception.new("Unexpected response code from OANDA API. See log entries with debug level to get more information.") unless resp.code == 200
    resp.body
  end

  def exchange_request(request_string)
    api_request request_string do
      RestClient.get "#{config[:api_url]}/#{config[:exchange_service]}", :params => {:fxmlrequest => request_string}
    end
  end

  def currencies_request
    api_request "" do
      RestClient.get "#{config[:api_url]}/#{config[:currencies]}"
    end
  end


  protected

  def extract_currencies
    xml_doc.search('CURRENCY').inject({}) do |hash, node|
      hash.merge node.at('CODE').content => node.at('COUNTRY').content
    end
  end

  def calculate_average_rate
    exchange_rates = extract_exchange_rates
    (exchange_rates.sum / exchange_rates.size).round(4) rescue BigDecimal.new '0'
  end

  def extract_exchange_rates
    extract_rates.map do |ask, bid|
      ((BigDecimal.new(ask) + BigDecimal.new(bid)) / 2).round(4)
    end
  end

  def extract_rates(options = {:first_currency => true})
    xml_doc.at('RESPONSE').search('CONVERSION').map{|el| [el.at('ASK').content, el.at('BID').content]}
  end

  def build_request
    Nokogiri::XML::Builder.new do |xml|
      xml.convert do
        xml.date date.strftime('%m/%d/%Y')
        xml.client_id config[:client_id]
        xml.exch base_currency
        xml.expr quote_currency
        xml.nprices days
        xml.amount amount
      end
    end.to_xml
  end

  def config
    OandaExchange::Config.get
  end

end