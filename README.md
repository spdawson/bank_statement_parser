# BankStatementParser

The `bank_statement_parser` gem allows simple parsing of English
language statements from HSBC bank in the UK. It is **highly** unlikely
that other banks and/or languages will ever be supported.

## Installation

### Rails with Bundler

Add the following line to the Gemfile of the application.
```ruby
gem 'bank_statement_parser'
```
Then run
```sh
bundle
```

### Manual installation

Run the following command.
```sh
gem install bank_statement_parser
```

## Rails configuration

Create the file `config/initializers/bank_statement_parser.rb`, containing
the following code.
```ruby
# Hook up the bank statement parser to use the Rails logger
BankStatementParser.logger = Rails.logger
```

## Example

```ruby
require 'bank_statement_parser'

# Plain text statement file path
file_path = 'January_2011.txt'

parser = BankStatementParser::HSBC.new
begin
  # Attempt to parse the file
  parser.parse(file_path)

  # Statement metadata
  puts "Account number %s, sort code %s, statement date %s" %
    [parser.sort_code,
     parser.account_number,
     parser.statement_date.to_s]

  # Statement records
  parser.records.each do |record|
    puts "Statement record #{record}"
  end
rescue StandardError => e
  puts "#{e}"
end
```
