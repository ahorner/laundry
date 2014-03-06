module Laundry
  module PaymentsGateway

    class ClientDriver < MerchantAuthenticatableDriver

      # Setup WSDL
      def self.wsdl
        if Laundry.sandboxed?
          "https://sandbox.paymentsgateway.net/WS/Client.wsdl"
        else
          "https://ws.paymentsgateway.net/Service/v1/Client.wsdl"
        end
      end

      actions "createClient", "getClient", "getPaymentMethod", "createPaymentMethod"

      def find(id)
        r = get_client({'ClientID' => id}) do
          http.headers["SOAPAction"] = 'https://ws.paymentsgateway.net/v1/IClientService/getClient'
        end
        Client.from_response(r, self.merchant)
      end

      # Creates a client and returns the newly created client id.
      def create!(options = {})
        options = ClientDriver.uglify_hash(options.merge(
          merchant_id: self.merchant.id,
          client_id: 0,
          status: "Active"))

        r = create_client("client" => ClientDriver.default_hash.merge(options)) do
          http.headers["SOAPAction"] = "https://ws.paymentsgateway.net/v1/IClientService/createClient"
        end
        r[:create_client_response][:create_client_result]
      end

      private

      def self.prettifiable_fields
        ['MerchantID',
         'ClientID',
         'FirstName',
         'LastName',
         'CompanyName',
         'Address1',
         'Address2',
         'City',
         'State',
         'PostalCode',
         'CountryCode',
         'PhoneNumber',
         'FaxNumber',
         'EmailAddress',
         'ShiptoFirstName',
         'ShiptoLastName',
         'ShiptoCompanyName',
         'ShiptoAddress1',
         'ShiptoAddress2',
         'ShiptoCity',
         'ShiptoState',
         'ShiptoPostalCode',
         'ShiptoCountryCode',
         'ShiptoPhoneNumber',
         'ShiptoFaxNumber',
         'ConsumerID',
         'Status']
      end
    end
  end
end
