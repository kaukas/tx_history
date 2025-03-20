# frozen_string_literal: true

require 'spec_helper'
require 'etherscan_stub'
require 'tx_history/cli'

RSpec.describe TxHistory::Cli do
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  before { allow(ENV).to receive(:fetch).with('ETHERSCAN_API_KEY').and_return('ETH_API_KEY') }

  it 'lists transactions for a wallet address' do
    EtherscanStub.stub_search(attributes_for(:eth))
    code = described_class.call(stdout, stderr, ['0xffffffffffffffffffffffffffffffffffffffff'])
    expect(code).to eq(0)
    expect(stdout.string).to eq("0000000042 to 0x7777777777777777777777777777777777777777 0.00000000000000001 ETH\n")
  end

  it 'requires a wallet address' do
    code = described_class.call(stdout, stderr, [])
    expect(code).to eq(1)
    expect(stderr.string).to eq("Missing wallet address\n")
  end

  it 'recognizes when the from and to wallet addresses match the queried one' do
    EtherscanStub.stub_search(attributes_for(:eth, from: '0xffffffffffffffffffffffffffffffffffffffff',
                                                   to: '0xffffffffffffffffffffffffffffffffffffffff'))
    code = described_class.call(stdout, stderr, ['0xffffffffffffffffffffffffffffffffffffffff'])
    expect(code).to eq(0)
    expect(stdout.string).to eq("0000000042 to itself 0.00000000000000001 ETH\n")
  end

  describe 'ERC-20' do
    it 'recognizes token transfers to another address' do
      EtherscanStub.stub_search(attributes_for(:erc20_transfer))
      described_class.call(stdout, stderr, ['0xffffffffffffffffffffffffffffffffffffffff'])
      expect(stdout.string).to eq("0000000042 to 0x2222222222222222222222222222222222222222 0.00000000000000002 FT\n")
    end

    it 'recognizes token transfers from another address' do
      EtherscanStub.stub_search(attributes_for(:erc20_transfer_from))
      described_class.call(stdout, stderr, ['0xffffffffffffffffffffffffffffffffffffffff'])
      expect(stdout.string).to eq(
        "0000000042 from 0x1111111111111111111111111111111111111111 to 0x2222222222222222222222222222222222222222 0.00000000000000002 FT\n"
      )
    end
  end
end
