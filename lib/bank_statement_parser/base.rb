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

module BankStatementParser

  # Base class for statement parsers
  #
  # Subclasses must implement the following instance methods
  #
  # * void reset()
  # * bool handle_line(String line)
  class Base

    require 'fileutils.rb'

    attr_accessor :sort_code, :account_number, :statement_date, :records

    # Constructor
    def initialize
      reset
    end

    # Parse the specified text file
    def parse path
      raise "Expected a text file path" unless path =~ /\.txt\z/

      reset

      # Grab the full text file content (utf-8)
      full_text = File.read(path)

      # Process each line in turn
      full_text.split("\n").each do |line|
        break unless handle_line(line)
      end

      # Sanity checking
      raise "Failed to find sort code" if @sort_code.nil?
      raise "Failed to find account number" if @account_number.nil?
      raise "Failed to find statement date" if @statement_date.nil?
    end

    protected

    # Convenience method to access the logger
    def logger
      BankStatementParser.logger
    end

    # Reset the parser
    def reset
      @sort_code = nil
      @account_number = nil
      @statement_date = nil
      @records = []
    end

  end
end
