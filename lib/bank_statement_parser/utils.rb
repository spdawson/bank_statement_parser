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

  # Utilities
  class Utils

    # Filter the specified text, re-encoding to ASCII
    def self.ascii_filter text
      rv = text

      # Squash some Unicode character categories
      #
      # {Zs} necessary to match statement date line
      # {Pc} necessary to match statement record lines
      rv.gsub!(/[\p{Zs}\p{Pc}]/, " ")

      # Replace Unicode soft hyphens
      rv.gsub!(/\u00ad/, "-")

      # Replace... well, who knows just *what* this is...
      rv.gsub!(/\u0a0c/, " ")

      # Re-encode to ASCII
      encoding_options = {
        invalid:           :replace, # Replace invalid byte sequences
        undef:             :replace, # Replace anything not defined in ASCII
        replace:           '',       # Use a blank for those replacements
        universal_newline: true      # Always break lines with \n
      }
      rv = rv.encode(Encoding.find('US-ASCII'), encoding_options)

      # Replace ASCII form feed characters
      rv.gsub!(/\f/, "\n")

      rv
    end

  end
end
