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
      tx_history.each { |tx| stdout.puts(format_transaction(wallet, tx)) }
      0
    end

    def self.format_transaction(wallet, tx)
      addresses = [
        tx[:from] == wallet ? nil : "from #{tx[:from]}",
        tx[:to] == wallet ? nil : "to #{tx[:to]}"
      ].compact
      addresses << 'to itself' if addresses.empty?

      format(
        '%<block>010d %<addresses>s %<eth>s %<asset>s',
        block: tx[:blockNumber], addresses: addresses.join(' '), eth: (tx[:wei].to_d / ETH_MULT).to_s('F'),
        asset: tx[:asset]
      )
    end
  end
end
