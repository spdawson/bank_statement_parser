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

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bank_statement_parser/version'

Gem::Specification.new do |s|
  s.name        = "bank_statement_parser"
  s.version     = BankStatementParser::VERSION
  s.date        = "2015-03-29"
  s.summary     = "Bank statement parser"
  s.description = "A gem for parsing bank statements"
  s.authors     = ["Simon Dawson"]
  s.email       = "spdawson@gmail.com"
  s.files       = ["lib/bank_statement_parser.rb",
                   "lib/bank_statement_parser/bank_statement.rb",
                   "lib/bank_statement_parser/base.rb",
                   "lib/bank_statement_parser/hsbc.rb",
                   "lib/bank_statement_parser/statement_record.rb",
                   "lib/bank_statement_parser/utils.rb"]
  s.executables << "bank_statement_to_yaml.rb"
  s.executables << "bank_statement_to_text.sh"
  s.homepage    =
    "https://github.com/spdawson/bank_statement_parser"
  s.license     = "GPLv3"
  s.required_ruby_version = ">= 2.0"
  s.requirements << "pdftotext(1)"

  s.add_development_dependency "rake"
end
