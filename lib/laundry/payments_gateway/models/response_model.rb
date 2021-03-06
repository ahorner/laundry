module Laundry
  module PaymentsGateway

    class MerchantNotSetError < StandardError; end

    # ResponseModel
    #
    # A container model for a serialized response and a
    # Laundry::PaymentsGateway::Merchant object.  The response is serialized
    # using to_hash if possible, otherwise it's initialized to an empty hash
    # and the value is stored in self.record
    class ResponseModel

      attr_accessor :record
      attr_accessor :merchant

      # ResponseModel.from_response(response, merchant)
      #
      # A constructor method for building ResponseModel objects from a response
      # and a merchant.  The response
      #
      # response - must implement a to_hash method
      # merchant - A Laundry Merchant object (?)
      def self.from_response(response, merchant)
        model = self.new
        model.merchant = merchant
        model.initialize_with_response response
        model
      end

      def initialize_with_response(response)
        self.record = response.try(:to_hash) || {}
      end

      def to_hash
        record.try(:to_hash)
      end

      def blank?
        record == {} || record.nil? || !record
      end

      def require_merchant!
        unless merchant && merchant.class == Laundry::PaymentsGateway::Merchant
          raise MerchantNotSetError, "Tried to call a method that requires a merchant to be set on the model. Try calling merchant= first."
        end
      end

      def method_missing(id, *args)
        return record[id.to_sym] if record.is_a?(Hash) && record.has_key?(id.to_sym)
        super
      end

      ## Support cleaner serialization to ActiveRecord
      ## Apparently supported in Rails >= 3.1

      # We don't want to serialize the merchant because it has upsetting
      # amounts of passwords in it.
      def dumpable
        d = self.dup
        d.merchant = nil
        d
      end

      def self.dump(model)
        model ? YAML::dump(model.dumpable) : nil
      end

      def self.load(model_text)
        model_text ? YAML::load(model_text) : nil
      end

    end

  end
end
