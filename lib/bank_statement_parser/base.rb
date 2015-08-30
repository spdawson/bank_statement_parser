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

require 'open-uri'
require 'bank_statement_parser/bank_statement'

module BankStatementParser

  # Base class for statement parsers
  #
  # Subclasses **must** implement the following instance methods
  #
  # * bool handle_line(String line)
  #
  # Subclasses *may* override the following instance methods, but **must**
  # remember to call the base class method from the override
  #
  # * void reset()
  class Base

    require 'fileutils.rb'

    attr_accessor :bank_statement

    # Constructor
    def initialize
      reset
    end

    # Parse the specified text file
    def parse path
      reset

      # Is the path a URI?
      full_text = if path =~ URI::regexp(%w(ftp http https))
                    open(path).read
                  else
                    raise "Expected a text file path" unless path =~ /\.txt\z/
                    # Grab the full text file content (utf-8)
                    read(path)
                  end

      # Process each line in turn
      full_text.split("\n").each do |line|
        break unless handle_line(line)
      end

      # Sanity checking
      raise "Failed to find sort code" if sort_code.nil?
      raise "Failed to find account number" if account_number.nil?
      raise "Failed to find statement date" if statement_date.nil?
    end

    protected

    # Convenience method to access the logger
    def logger
      BankStatementParser.logger
    end

    # Reset the parser
    def reset
      @bank_statement = BankStatement.new
    end

    # @todo FIXME: Why can't we use Forwardable for these methods?
    #
    # Partially works, but doesn't seem to be accessible from subclasses...

    def name
      @bank_statement.name
    end

    def name= name
      @bank_statement.name = name
    end

    def sort_code
      @bank_statement.sort_code
    end

    def sort_code= sort_code
      @bank_statement.sort_code = sort_code
    end

    def account_number
      @bank_statement.account_number
    end

    def account_number= account_number
      @bank_statement.account_number = account_number
    end

    def statement_date
      @bank_statement.statement_date
    end

    def statement_date= statement_date
      @bank_statement.statement_date = statement_date
    end

    def opening_balance
      @bank_statement.opening_balance
    end

    def opening_balance= opening_balance
      @bank_statement.opening_balance = opening_balance
    end

    def closing_balance
      @bank_statement.closing_balance
    end

    def closing_balance= closing_balance
      @bank_statement.closing_balance = closing_balance
    end

    def add_record record
      @bank_statement.records << record
    end

  end
end
