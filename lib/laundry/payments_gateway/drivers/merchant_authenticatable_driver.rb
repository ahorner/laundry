module Laundry
  module PaymentsGateway

    class MerchantAuthenticatableDriver
      extend Laundry::SOAPModel

      attr_accessor :merchant

      def initialize(merchant)
        # Save the merchant.
        self.merchant = merchant
        self.class.document document if respond_to?(:document)
      end

      def default_body
        # Log in via the merchant's login credentials.
        self.merchant.login_credentials.merge("MerchantID" => self.merchant.id)
      end

      def self.default_fields
        []
      end

      def self.prettifiable_fields
        []
      end

      def self.uglify_hash(hash)
        translation = {}
        self.prettifiable_fields.each do |f|
          translation[f.snakecase.to_sym] = f
        end
        ugly_hash = {}
        hash.each do |k, v|
          if translation.has_key?(k)
            ugly_hash[translation[k]] = v
          else
            ugly_hash[k] = v
          end
        end
        ugly_hash
      end

      def self.default_hash
        h = {}
        self.default_fields.each do |f|
          h[f] = nil
        end
        h
      end

      def self.apply(options)
        default_hash.merge(options).reject { |k, v| v.nil? }
      end
    end
  end
end
