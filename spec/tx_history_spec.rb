# frozen_string_literal: true

require 'spec_helper'
require 'etherscan_stub'

RSpec.describe TxHistory do
  subject(:history) { described_class.new('ETH_API_KEY').query('0xffffffffffffffffffffffffffffffffffffffff') }

  it 'returns a list of transactions for a wallet address' do
    EtherscanStub.stub_search(attributes_for(:eth))
    expect(history).to eq([{ blockNumber: 42, from: '0xffffffffffffffffffffffffffffffffffffffff',
                             to: '0x7777777777777777777777777777777777777777', wei: 10, asset: 'ETH' }])
  end
end
