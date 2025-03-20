# frozen_string_literal: true

require 'optparse'
require 'bigdecimal/util'
require_relative 'tx_history'

class TxHistory
  # Handles command line interface for TxHistory.
  module Cli
    ETH_MULT = 10.to_d**18.to_d

    def self.call(stdout, _stderr, args)
      help = false
      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: tx_history [options] WALLET_ADDRESS'
        opts.on('-h', '--help', 'Prints this help') do
          help = true
        end
      end

      wallet, = parser.parse(args)
      if help || wallet.nil? || wallet.empty?
        stdout.puts(parser)
        return 0
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

      eth = (tx[:wei].to_d / ETH_MULT).to_s('F')
      eth = 'unknown' if tx[:asset].nil?

      [format('%010d', tx[:blockNumber]), addresses, eth, tx[:asset]].compact.join(' ')
    end
  end
end
