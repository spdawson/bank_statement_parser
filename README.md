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

## Adding support for a new bank

To add a parser for a new type of bank statement, simply subclass
`BankStatementParser::Base` and implement the `handle_line()` method.

Optionally, you can override the `reset()` method to perform class-specific
reset work; however, you **must** remember to call the base class `reset()`
from the override.

An example parser follows.
```rb
class Barclays < BankStatementParser::Base

  def handle_line line
    # Keep going if we manage to parse the line
    return true if do_something_with_line(line)

    # Otherwise, halt the parser
    return false
  end

  private

  def reset
    # Reset the base class
    super

    # Perform class-specific parser reset work here
  end

  def do_something_with_line line
    # Implement class-specific line parsing here
    return false
  end

end
```