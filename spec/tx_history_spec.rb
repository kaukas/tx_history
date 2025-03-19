# frozen_string_literal: true

RSpec.describe TxHistory do
  def stub_transaction(tx_override)
    uri = URI('https://api.etherscan.io/api')
    uri.query = URI.encode_www_form({ module: 'account', action: 'txlist',
                                      address: '0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC', startblock: 0,
                                      endblock: 99_999_999, sort: 'asc', apikey: 'ETH_API_KEY' })
    stub_request(:get, uri.to_s)
      .to_return(
        status: 200,
        body: JSON.dump({ result: [{ blockNumber: '1', from: '0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC',
                                     to: '0x9aa99c23f67c81701c772b106b4f83f6e858dd2e', value: '0',
                                     methodId: '0x' }.merge(tx_override)] }),
        headers: {}
      )
  end

  it 'returns a list of transactions for a wallet address' do
    stub_transaction(value: '100')
    tx_history = described_class.new('ETH_API_KEY').query('0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC')
    expect(tx_history).to eq([{ blockNumber: 1, from: '0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC',
                                to: '0x9aa99c23f67c81701c772b106b4f83f6e858dd2e', wei: 100, asset: 'ETH' }])
  end
end
