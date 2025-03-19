# frozen_string_literal: true

require 'json'
require 'net/http'

require_relative 'tx_decoder'

# Fetches transaction history for a given wallet address.
class TxHistory
  def initialize(api_key)
    @api_key = api_key
  end

  def query(wallet)
    resp = response(wallet)
    parse_transactions(resp.body)
  end

  private

  def response(wallet)
    request = Net::HTTP::Get.new(uri(wallet))
    Net::HTTP.start('api.etherscan.io', use_ssl: true) { |http| http.request(request) }
  end

  def uri(wallet)
    uri = URI('https://api.etherscan.io/api')
    uri.query = URI.encode_www_form({ module: 'account', action: 'txlist', address: wallet, startblock: 0,
                                      endblock: 99_999_999, sort: 'asc', apikey: @api_key })
    uri
  end

  def parse_transactions(body)
    transactions = JSON.parse(body, symbolize_names: true)
    transactions[:result].map { |tx| TxDecoder.decode(tx) }
  end
end
