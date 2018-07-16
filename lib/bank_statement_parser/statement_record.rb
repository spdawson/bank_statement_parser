# Copyright 2015-2018 Simon Dawson <spdawson@gmail.com>

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

require 'yaml'
require 'bank_statement_parser/statement_record_types'

module BankStatementParser

  # A bank statement record
  class StatementRecord
    attr_accessor :date, :type, :record_type, :credit, :amount, :detail, :balance

    # Constructor
    def initialize date: nil, type: nil, record_type: nil, credit: nil, amount: nil, detail: nil,
      balance: nil

      # Sanity check the record type parameter
      known_record_types = StatementRecordTypes.constants(false).map do |k|
        StatementRecordTypes.const_get(k, false)
      end
      raise "Unknown statement record type #{record_type}" unless
        known_record_types.include?(record_type)

      @date = date
      @type = type
      @record_type = record_type
      @credit = credit
      @amount = amount
      @detail = detail
      @balance = balance
    end

    # Stringify
    def to_s
      to_yaml
    end

    # Equality test
    def ==(other)
      super || (date == other.date &&
                type == other.type &&
                record_type == other.record_type &&
                credit == other.credit &&
                amount == other.amount &&
                detail == other.detail &&
                balance == other.balance)
    end
  end

end
