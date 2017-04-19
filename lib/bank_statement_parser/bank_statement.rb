# Copyright 2015-2017 Simon Dawson <spdawson@gmail.com>

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

  # A bank statement
  class BankStatement
    attr_accessor :name, :sort_code, :account_number, :statement_date,
      :opening_balance, :closing_balance, :records

    # Constructor
    def initialize
      @records = []
    end

    # Stringify
    def to_s
      to_yaml
    end

    # Equality test
    def ==(other)
      super || (name == other.name &&
                sort_code == other.sort_code &&
                account_number == other.account_number &&
                statement_date == other.statement_date &&
                opening_balance == other.opening_balance &&
                closing_balance == other.closing_balance &&
                records == other.records)
    end
  end

end
