# frozen_string_literal: true

require 'tx_history/cli'

RSpec.describe TxHistory::Cli do
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  it 'lists transactions for a wallet address' do
    allow(ENV).to receive(:fetch).with('ETHERSCAN_API_KEY').and_return('ETH_API_KEY')
    uri = URI('https://api.etherscan.io/api')
    uri.query = URI.encode_www_form({ module: 'account', action: 'txlist',
                                      address: '0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC', startblock: 0,
                                      endblock: 99_999_999, sort: 'asc', apikey: 'ETH_API_KEY' })
    stub_request(:get, uri.to_s)
      .to_return(
        status: 200,
        body: JSON.dump({ result: [{ blockNumber: '1', from: '0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC',
                                     to: '0x9aa99c23f67c81701c772b106b4f83f6e858dd2e', value: '1000' }] }),
        headers: {}
      )

    code = described_class.call(stdout, stderr, ['0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC'])
    expect(code).to eq(0)
    expect(stdout.string).to eq(
      "0000000001 to 0x9aa99c23f67c81701c772b106b4f83f6e858dd2e 0.000000000000001 ETH\n"
    )
  end

  it 'requires a wallet address' do
    code = described_class.call(stdout, stderr, [])
    expect(code).to eq(1)
    expect(stderr.string).to eq("Missing wallet address\n")
  end
end
