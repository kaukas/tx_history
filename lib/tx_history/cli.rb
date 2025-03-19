# frozen_string_literal: true

require 'bigdecimal/util'
require_relative 'tx_history'

class TxHistory
  # Handles command line interface for TxHistory.
  module Cli
    ETH_MULT = 10.to_d**18.to_d

    def self.call(stdout, stderr, args)
      wallet = args[0]
      if wallet.nil? || wallet.empty?
        stderr.puts('Missing wallet address')
        return 1
      end

      tx_history = TxHistory.new(ENV.fetch('ETHERSCAN_API_KEY')).query(wallet)
      tx_history.each do |tx|
        # FIXME
        from_to, other_wallet = if tx[:to] == wallet
                                  ['from', tx[:from]]
                                else
                                  ['to', tx[:to]]
                                end
        stdout.puts(
          format(
            '%<block>010d %<from_to>s %<other>s %<eth>s %<unit>s',
            block: tx[:blockNumber], from_to:, other: other_wallet, eth: (tx[:wei].to_d / ETH_MULT).to_s('F'),
            unit: 'ETH'
          )
        )
      end.join
      0
    end
  end
end
