#!/usr/bin/env ruby
#
# Parse the specified HSBC bank statement file to YAML

# Copyright 2015 Simon Dawson <spdawson@gmail.com>

# This file is part of bank_statement_parser.
#
# bank_statement_parser is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# bank_statement_parser is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with bank_statement_parser. If not, see <http://www.gnu.org/licenses/>.

require 'bank_statement_parser'

parser = BankStatementParser::HSBC.new

# Attempt to parse the specified file
parser.parse ARGV[0]

# Statement metadata
puts <<METADATA
bank_statement:
  account_number: #{parser.account_number}
  sort_code: #{parser.sort_code}
  statement_date: #{parser.statement_date}
  records:
METADATA

# Statement records
parser.records.each do |record|
  puts <<RECORD
    - date: #{record.date}
      type: #{record.type}
      credit: #{record.credit}
      amount: #{record.amount || ''}
      detail: #{record.detail}
      balance: #{record.balance || ''}
RECORD
end
