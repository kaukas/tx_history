# frozen_string_literal: true

FactoryBot.define do
  # Transactions in Etherscan API format.

  factory :eth, class: Hash do
    blockNumber { '42' }
    from { '0xffffffffffffffffffffffffffffffffffffffff' }
    to { '0x7777777777777777777777777777777777777777' }
    value { '10' }
    methodId { '0x' }
    input { '0x' }
    functionName { '' }

    factory :erc20_transfer do
      transient do
        _to { '0x2222222222222222222222222222222222222222' }
        _value { '20' }
      end

      methodId { '0xa9059cbb' }
      functionName { 'transfer(address _to, uint256 _value)' }
      value { '0' }

      input { format('%<methodId>s%<_to>064x%<_value>064x', methodId:, _to: Integer(_to), _value:) }
    end

    factory :erc20_transfer_from do
      transient do
        _from { '0x1111111111111111111111111111111111111111' }
        _to { '0x2222222222222222222222222222222222222222' }
        _value { '20' }
      end

      methodId { '0x23b872dd' }
      functionName { 'transferFrom(address _from, address _to, uint256 _value)' }
      value { '0' }

      input do
        format('%<methodId>s%<_from>064x%<_to>064x%<_value>064x',
               methodId:, _from: Integer(_from), _to: Integer(_to), _value:)
      end
    end
  end
end
