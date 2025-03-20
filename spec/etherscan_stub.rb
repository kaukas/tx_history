# frozen_string_literal: true

module EtherscanStub
  class << self
    include WebMock::API

    def stub_search(*transactions)
      uri = URI('https://api.etherscan.io/api')
      uri.query = URI.encode_www_form({ module: 'account', action: 'txlist',
                                        address: '0xffffffffffffffffffffffffffffffffffffffff', startblock: 0,
                                        endblock: 99_999_999, sort: 'asc', apikey: 'ETH_API_KEY' })
      stub_request(:get, uri.to_s).to_return(status: 200, body: JSON.dump({ result: transactions }), headers: {})
    end
  end
end
