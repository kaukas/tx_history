# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TxHistory::TxDecoder do
  def decode(input)
    described_class.decode(input)
  end

  it 'recognizes ETH transfers' do
    expect(decode(attributes_for(:eth)))
      .to eq(blockNumber: 42, from: '0xffffffffffffffffffffffffffffffffffffffff',
             to: '0x7777777777777777777777777777777777777777', wei: 10, asset: 'ETH')
  end

  describe 'ERC-20' do
    it 'recognizes token transfers to another address' do
      expect(decode(attributes_for(:erc20_transfer)))
        .to eq({ blockNumber: 42, from: '0xffffffffffffffffffffffffffffffffffffffff',
                 to: '0x2222222222222222222222222222222222222222', methodId: '0xa9059cbb',
                 functionName: 'transfer(address _to, uint256 _value)', asset: 'FT', wei: 20 })
    end

    it 'recognizes token transfers from another address' do
      expect(decode(attributes_for(:erc20_transfer_from)))
        .to eq({ blockNumber: 42, from: '0x1111111111111111111111111111111111111111',
                 to: '0x2222222222222222222222222222222222222222', methodId: '0x23b872dd',
                 functionName: 'transferFrom(address _from, address _to, uint256 _value)', asset: 'FT', wei: 20 })
    end
  end

  it 'returns no wei nor asset when transaction not recognized' do
    expect(decode(attributes_for(:erc20_transfer).merge(input: '0xdeadbeef')))
      .to eq({ blockNumber: 42, from: '0xffffffffffffffffffffffffffffffffffffffff',
               to: '0x7777777777777777777777777777777777777777', methodId: '0xa9059cbb',
               functionName: 'transfer(address _to, uint256 _value)' })
  end
end
