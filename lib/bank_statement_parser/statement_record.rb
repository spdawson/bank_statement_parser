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

require 'yaml'

module BankStatementParser

  # A bank statement record
  class StatementRecord
    attr_accessor :date, :type, :credit, :amount, :detail, :balance

    # Constructor
    def initialize date: nil, type: nil, credit: nil, amount: nil, detail: nil,
      balance: nil

      @date = date
      @type = type
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
                credit == other.credit &&
                amount == other.amount &&
                detail == other.detail &&
                balance == other.balance)
    end
  end

end
