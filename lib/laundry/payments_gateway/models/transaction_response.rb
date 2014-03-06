module Laundry
	module PaymentsGateway

		class TransactionResponse < ResponseModel

			ERRORS = {
				'U01' => 'Merchant not allowed to access customer account',
				'U02' => 'Customer account is in the ACH Direct "known bad" list',
				'U03' => 'Merchant daily limit exceeded',
				'U04' => 'Merchant monthly limit exceeded',
				'U05' => 'AVS state/zipcode check failed',
				'U06' => 'AVS state/area code check failed',
				'U07' => 'AVS anonymous email check failed',
				'U08' => 'Account has more transactions than the merchant\'s daily velocity limit allows for',
				'U09' => 'Account has more transactions than the merchant\'s velocity window allows for',
				'U10' => 'Transaction has the same attributes as another transaction within the time set by the merchant',
				'U11' => '(RECUR TRANS NOT FOUND) Transaction types 40-42 only',
				'U12' => 'Original transaction not voidable or capture-able',
				'U13' => 'Transaction to be voided or captured was not found',
				'U14' => 'void/capture and original transaction types do not agree (CC/EFT)',
				'U18' => 'Void or Capture failed',
				'U19' => 'Account ABA number is invalid',
				'U20' => 'Credit card number is invalid',
				'U21' => 'Date is malformed',
				'U22' => 'Swipe data is malformed',
				'U23' => 'Malformed expiration date',
				'U51' => 'Merchant is not "live"',
				'U52' => 'Merchant not approved for transaction type (CC or EFT)',
				'U53' => 'Transaction amount exceeds merchant\'s per transaction limit',
				'U54' => 'Merchant\'s configuration requires updating - call customer support',
				'U80' => 'Transaction was declined due to preauthorization (ATM Verify) result',
				'U84' => 'Preauthorizer not responding',
				'U85' => 'Preauthorizer error',
				'U83' => 'Transaction was declined due to authorizer declination',
				'U84' => 'Authorizer not responding',
				'U85' => 'Authorizer error',
				'U86' => 'Authorizer AVS check failed',
				'F01' => 'Required field is missing',
				'F03' => 'Name is not recognized',
				'F04' => 'Value is not allowed',
				'F05' => 'Field is repeated in message',
				'F07' => 'Fields cannot both be present',
				'E10' => 'Merchant id or password is incorrect',
				'E20' => 'Transaction message not received (I/O flush required?)',
				'E90' => 'Originating IP not on merchant\'s approved IP list',
				'E99' => 'An unspecified error has occurred' }

			def initialize_with_response(response)
				self.record = parse(response)
			end

			def success?
				pg_response_type == 'A'
			end

			def full_transaction
				require_merchant!
				self.merchant.transactions.find pg_payment_method_id, pg_trace_number
			end

			def error_reason
				ERRORS[pg_response_code] unless success?
			end

			private

			def parse(response)
				return response if response.is_a? Hash
				data = {}
				res = response[:execute_socket_query_response][:execute_socket_query_result].split("\n")
				res.each do |key_value_pair|
					kv = key_value_pair.split('=')
					if kv.size == 2
						data[ kv[0].to_sym ] = kv[1]
					end
				end
				data
			end

		end

	end
end
