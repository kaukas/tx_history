# frozen_string_literal: true

require 'optparse'
require 'bigdecimal/util'
require_relative 'tx_history'

class TxHistory
  # Handles command line interface for TxHistory.
  module Cli
    ETH_MULT = 10.to_d**18.to_d

    def self.call(stdout, stderr, args)
      catch(:exit_code) do
        format, wallet = opt_parser(stdout, stderr, args)
        tx_history = TxHistory.new(ENV.fetch('ETHERSCAN_API_KEY')).query(wallet)
        case format
        when 'json'
          stdout.puts(format_transactions_json(tx_history))
        else
          tx_history.each { |tx| stdout.puts(format_transaction_text(wallet, tx)) }
        end
        0
      end
    end

    def self.opt_parser(stdout, stderr, args)
      help = false
      format = 'text'
      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: tx_history [options] WALLET_ADDRESS'
        opts.on('-f', '--format text|json', 'Output format') do |fmt|
          if %w[json text].include?(fmt)
            format = fmt
          else
            stderr.puts('Invalid format, expected text or json')
            throw :exit_code, 1
          end
        end
        opts.on('-h', '--help', 'Prints this help') { help = true }
      end
      wallet, = parser.parse(args)
      if help || wallet.nil? || wallet.empty?
        stdout.puts(parser)
        throw :exit_code, 0
      end
      [format, wallet]
    end

    def self.format_transactions_json(trxs)
      JSON.dump(trxs)
    end

    def self.format_transaction_text(wallet, trx)
      addresses = format_addresses(wallet, trx)
      eth = trx[:asset].nil? ? 'unknown' : (trx[:wei].to_d / ETH_MULT).to_s('F')
      [format('%010d', trx[:blockNumber]), addresses, eth, trx[:asset]].compact.join(' ')
    end

    def self.format_addresses(wallet, trx)
      addresses = [
        trx[:from] == wallet ? nil : "from #{trx[:from]}",
        trx[:to] == wallet ? nil : "to #{trx[:to]}"
      ].compact
      addresses << 'to itself' if addresses.empty?
      addresses.join(' ')
    end
  end
end
