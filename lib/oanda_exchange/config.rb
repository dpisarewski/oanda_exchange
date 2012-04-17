require "logger"
require "active_support/core_ext/hash"

module OandaExchange
  class Config

    def self.get
      @@config ||= YAML::load_file(File.join(root, "config", "oanda_api.yml")).symbolize_keys or raise Exception.new("Error on loading configuration file for OANDA API")
    end

    def self.root
      rails_root || "."
    end

    def self.logger
      @@logger ||= rails_logger || Logger.new(STDOUT)
    end

    def self.rails_root
      if defined?(Rails) then Rails.root elsif defined?(RAILS_ENV) then RAILS_ENV end
    end

    def self.rails_logger
      if defined?(Rails) then Rails.logger elsif defined?(RAILS_DEFAULT_LOGGER) then RAILS_DEFAULT_LOGGER end
    end
  end
end

