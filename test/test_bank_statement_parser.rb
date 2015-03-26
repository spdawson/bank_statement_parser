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
      fixture = YAML.load_file fixture_file
      bs = fixture['bank_statement']

      parser = BankStatementParser::HSBC.new
      parser.parse statement_file

      assert_equal bs['account_number'].to_s, parser.account_number
      assert_equal bs['sort_code'], parser.sort_code
      assert_equal bs['statement_date'], parser.statement_date

      bs['records'].each_index do |index|
        parsed_i = parser.records[index]
        expected_i = bs['records'][index]
        assert_equal expected_i['date'], parsed_i.date
        assert_equal expected_i['type'], parsed_i.type
        assert_equal expected_i['credit'], parsed_i.credit
        assert_equal expected_i['amount'], parsed_i.amount
        assert_equal expected_i['detail'].to_s, parsed_i.detail
        assert_equal expected_i['balance'], parsed_i.balance
      end
    end

  end

end
