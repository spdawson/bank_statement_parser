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

module BankStatementParser

  # Constants to enumerate bank statement record types
  module StatementRecordTypes
    ATM = :atm
    BILL_PAYMENT = :bill_payment
    CHEQUE = :cheque
    CIRRUS = :cirrus
    CREDIT = :credit
    DIRECT_DEBIT = :direct_debit
    DIVIDEND = :dividend
    DEBIT = :debit
    INTEREST = :interest
    MAESTRO = :maestro
    PAYING_IN_MACHINE = :paying_in_machine
    STANDING_ORDER = :standing_order
    TRANSFER = :transfer
    VISA = :visa
    CONTACTLESS = :contactless
    INTERNET_ACCESS_PAYMENT = :internet_access_payment
  end

end
