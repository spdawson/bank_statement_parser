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

require 'logger'
require 'bank_statement_parser/hsbc'
module BankStatementParser

  @@logger = Logger.new(STDERR)
  def self.logger
    @@logger
  end
  def self.logger=(logger)
    @@logger = logger
  end

  # Parse the specified statement file, for the specified (by name) bank
  #
  # Returns an instance of BankStatement
  def self.parse path, bank = 'HSBC'
    parser_class = Kernel.const_get(self.name + '::' + bank)
    raise "No parser for #{bank} statements" unless Class == parser_class.class

    parser = parser_class.new
    parser.parse path

    return parser.bank_statement
  end

end
