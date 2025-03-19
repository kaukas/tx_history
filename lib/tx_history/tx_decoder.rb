# frozen_string_literal: true

class TxHistory
  # Decodes transaction data, recognizes ETH, FT, NFT transfers.
  module TxDecoder
    def self.decode(trx)
      { from: trx[:from], to: trx[:to], blockNumber: Integer(trx[:blockNumber]) }.merge(asset_properties(trx))
    end

    def self.asset_properties(trx)
      method_id = trx[:methodId]
      if method_id.nil? || method_id.empty? || method_id == '0x'
        { asset: 'ETH', wei: Integer(trx[:value]) }
      else
        { methodId: method_id, functionName: trx[:functionName],
          asset: 'FT' }.merge(naive_parse_input(method_id, trx[:functionName], trx[:input]))
      end
    end

    def self.naive_parse_input(_method_id, _function_signature, input)
      case input

      # ERC-20: transfer(address _to, uint256 _value)
      when /^0xa9059cbb([a-f0-9]{64})([a-f0-9]{64})$/
        to, value = Regexp.last_match[1..]
        { to: "0x#{to[-40..]}", wei: Integer("0x#{value}") }

      # ERC-20: transferFrom(address _from, address _to, uint256 _value)
      when /^0x23b872dd([a-f0-9]{64})([a-f0-9]{64})([a-f0-9]{64})$/
        from, to, value = Regexp.last_match[1..]
        { from: "0x#{from[-40..]}", to: "0x#{to[-40..]}", wei: Integer("0x#{value}") }
      end
    end
  end
end
