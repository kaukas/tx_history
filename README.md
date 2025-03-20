# TxHistory

This gem provides a command-line tool to get the transaction history of a wallet address. The implementation is rather naive:

- Up to 10.000 transactions are fetched from Etherscan API (no pagination).
- Only a few most common types of transactions are recognized (more to be implemented):
    - An ether transfer.
    - An ERC20 token transfer.
- The contract implementations are not resolved nor executed; their parameters are used to infer the from and to addresses, and the amount of tokens transferred. This is very naive and incomplete.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add https://github.com/kaukas/tx_history
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install https://github.com/kaukas/tx_history
```

## Usage

Specify a wallet address to get the transaction history:

```sh
bundle exec tx_history 0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae
```

This command expects an Etherscan API key in the `ETHERSCAN_API_KEY` environment variable.

Transactions can be printed in JSON format, too:

```sh
bundle exec tx_history --format json 0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kaukas/tx\_history](https://github.com/kaukas/tx_history).
