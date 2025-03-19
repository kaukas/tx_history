# frozen_string_literal: true

RSpec.describe TxHistory::TxDecoder do
  def decode(input)
    described_class.decode(input)
  end

  it 'recognizes ETH transfers' do
    expect(
      decode(
        blockNumber: '1', from: '0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC',
        to: '0x9aa99c23f67c81701c772b106b4f83f6e858dd2e', value: '100',
        methodId: '0x'
      )
    ).to eq({ blockNumber: 1, from: '0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC',
              to: '0x9aa99c23f67c81701c772b106b4f83f6e858dd2e', wei: 100, asset: 'ETH' })
  end

  describe 'ERC-20' do
    it 'recognizes token transfers to another address' do
      expect(
        decode(
          blockNumber: '1', from: '0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC',
          methodId: '0xa9059cbb',
          functionName: 'transfer(address _to, uint256 _value)',
          input: '0xa9059cbb' \
                 '000000000000000000000000be87e9ad6e722e4c7f558297cc06be45b0be1729' \
                 '00000000000000000000000000000000000000000000000000042ad9c123f6e2'
        )
      ).to eq({ blockNumber: 1, from: '0xc5102fE9359FD9a28f877a67E36B0F050d81a3CC',
                to: '0xbe87e9ad6e722e4c7f558297cc06be45b0be1729', methodId: '0xa9059cbb',
                functionName: 'transfer(address _to, uint256 _value)', asset: 'FT', wei: 1_173_014_643_472_098 })
    end

    it 'recognizes token transfers from another address' do
      expect(
        decode(
          blockNumber: '1',
          methodId: '0x23b872dd',
          functionName: 'transferFrom(address _from, address _to, uint256 _value)',
          input: '0x23b872dd' \
                 '000000000000000000000000de0b295669a9fd93d5f28d9ec85e40f4cb697bae' \
                 '000000000000000000000000153685a03c2025b6825ae164e2ff5681ee487667' \
                 '0000000000000000000000000000000000000000000000000000000000004e20'
        )
      ).to eq({ blockNumber: 1, from: '0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae',
                to: '0x153685a03c2025b6825ae164e2ff5681ee487667', methodId: '0x23b872dd',
                functionName: 'transferFrom(address _from, address _to, uint256 _value)', asset: 'FT',
                wei: 20_000 })
    end
  end
end
