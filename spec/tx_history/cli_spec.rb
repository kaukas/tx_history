# frozen_string_literal: true

require 'spec_helper'
require 'etherscan_stub'
require 'tx_history/cli'

RSpec.describe TxHistory::Cli do
  subject(:invoke) { described_class.call(stdout, stderr, ['0xffffffffffffffffffffffffffffffffffffffff']) }

  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  before { allow(ENV).to receive(:fetch).with('ETHERSCAN_API_KEY').and_return('ETH_API_KEY') }

  it 'lists transactions for a wallet address' do
    EtherscanStub.stub_search(attributes_for(:eth))
    code = invoke
    expect(code).to eq(0)
    expect(stdout.string).to eq("0000000042 to 0x7777777777777777777777777777777777777777 0.00000000000000001 ETH\n")
  end

  it 'prints transactions as json' do
    EtherscanStub.stub_search(attributes_for(:erc20_transfer))
    described_class.call(stdout, stderr, ['--format', 'json', '0xffffffffffffffffffffffffffffffffffffffff'])
    expect(JSON.parse(stdout.string)).to eq(
      [{
        'blockNumber' => 42,
        'from' => '0xffffffffffffffffffffffffffffffffffffffff', 'to' => '0x2222222222222222222222222222222222222222',
        'methodId' => '0xa9059cbb', 'functionName' => 'transfer(address _to, uint256 _value)',
        'wei' => 20, 'asset' => 'FT'
      }]
    )
  end

  it 'fails on unknown format' do
    EtherscanStub.stub_search(attributes_for(:eth))
    code = described_class.call(stdout, stderr, ['--format', 'csv', '0xffffffffffffffffffffffffffffffffffffffff'])
    expect(code).to eq(1)
    expect(stderr.string).to eq("Invalid format, expected text or json\n")
  end

  it 'recognizes when the from and to wallet addresses match the queried one' do
    EtherscanStub.stub_search(attributes_for(:eth, from: '0xffffffffffffffffffffffffffffffffffffffff',
                                                   to: '0xffffffffffffffffffffffffffffffffffffffff'))
    invoke
    expect(stdout.string).to eq("0000000042 to itself 0.00000000000000001 ETH\n")
  end

  describe 'ERC-20' do
    it 'recognizes token transfers to another address' do
      EtherscanStub.stub_search(attributes_for(:erc20_transfer))
      invoke
      expect(stdout.string).to eq("0000000042 to 0x2222222222222222222222222222222222222222 0.00000000000000002 FT\n")
    end

    it 'recognizes token transfers from another address' do
      EtherscanStub.stub_search(attributes_for(:erc20_transfer_from))
      invoke
      expect(stdout.string).to eq(
        '0000000042 from 0x1111111111111111111111111111111111111111 to 0x2222222222222222222222222222222222222222 ' \
        "0.00000000000000002 FT\n"
      )
    end
  end

  it 'passes some fields through for unrecognized transactions' do
    EtherscanStub.stub_search(attributes_for(:erc20_transfer).merge(input: '0xdeadbeef'))
    invoke
    expect(stdout.string).to eq("0000000042 to 0x7777777777777777777777777777777777777777 unknown\n")
  end

  it 'prints help on --help' do
    code = described_class.call(stdout, stderr, ['--help'])
    expect(code).to eq(0)
    expect(stdout.string).to eq(<<~HELP)
      Usage: tx_history [options] WALLET_ADDRESS
          -f, --format text|json           Output format
          -h, --help                       Prints this help
    HELP
  end

  it 'prints help on -h' do
    code = described_class.call(stdout, stderr, ['-h'])
    expect(code).to eq(0)
    expect(stdout.string.lines[0]).to eq("Usage: tx_history [options] WALLET_ADDRESS\n")
  end

  it 'prints help on no arguments' do
    # Prints help when no arguments are given.
    code = described_class.call(stdout, stderr, [])
    expect(code).to eq(0)
    expect(stdout.string.lines[0]).to eq("Usage: tx_history [options] WALLET_ADDRESS\n")
  end

  it 'ignores other arguments on --help' do
    code = described_class.call(stdout, stderr, ['--help', '0xffffffffffffffffffffffffffffffffffffffff'])
    expect(code).to eq(0)
    expect(stdout.string.lines[0]).to eq("Usage: tx_history [options] WALLET_ADDRESS\n")
  end
end
