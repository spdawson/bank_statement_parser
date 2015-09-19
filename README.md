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

Parse a statement file from the local filesystem:

```ruby
require 'bank_statement_parser'

# Plain text statement file path
file_path = 'January_2011.txt'

begin
  # Attempt to parse the file
  bank_statement = BankStatementParser.parse file_path, :hsbc

  # Statement metadata
  puts "Name %s, account number %s, sort code %s, statement date %s" %
    [bank_statement.name,
     bank_statement.account_number,
     bank_statement.sort_code,
     bank_statement.statement_date.to_s]
  puts "Opening balance %f, closing balance %f" %
    [bank_statement.opening_balance,
     bank_statement.closing_balance]

  # Statement records
  bank_statement.records.each do |record|
    puts "Statement record #{record}"
  end
rescue StandardError => e
  puts "#{e}"
end
```

Parse a statement file from an FTP, HTTP or HTTPS server:

```ruby
require 'bank_statement_parser'

statement_uri = 'http://statement.bank.com/mine/2011/01.txt'
bank_statement = BankStatementParser.parse statement_uri
```

The `BankStatementParser.parse` method can be passed a `String`, `File`, `IO`,
`Pathname`, `StringIO`, `Tempfile` or `URI`. A `String` is interpreted as a
file path, or as a URI if it has a `ftp://`, `http://` or `https://` prefix.

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

## HSBC statements

HSBC statements produced from 13 July 2014 are available in PDF format. Earlier statements can be "printed" from the web view, and thus saved as PDF. This parser should work with either of these types of statement, following conversion from PDF to plain text.

A utility script `bank_statement_to_text.sh` is provided, which uses `pdftotext(1)` to convert a statement PDF to a plain text file suitable for parsing.

## License

Copyright 2015 Simon Dawson <spdawson@gmail.com>

bank_statement_parser is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

bank_statement_parser is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with bank_statement_parser. If not, see <http://www.gnu.org/licenses/>.
