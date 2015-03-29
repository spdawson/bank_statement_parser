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

require 'minitest/autorun'
require 'bank_statement_parser.rb'

class BankStatementParserTest < Minitest::Test

  def test_parser

    Dir.glob('test/data/*.txt') do |statement_file|
      fixture_file =
        'test/fixtures/' + File.basename(statement_file, '.txt') + '.yml'
      bs = YAML.load_file fixture_file

      parsed_bs = BankStatementParser.parse statement_file

      assert_equal bs, parsed_bs, "Failed to parse #{statement_file}"
    end

  end

end
