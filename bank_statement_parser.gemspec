Gem::Specification.new do |s|
  s.name        = "bank_statement_parser"
  s.version     = "0.0.9"
  s.date        = "2015-03-26"
  s.summary     = "Bank statement parser"
  s.description = "A gem for parsing bank statements"
  s.authors     = ["Simon Dawson"]
  s.email       = "spdawson@gmail.com"
  s.files       = ["lib/bank_statement_parser.rb",
                   "lib/bank_statement_parser/base.rb",
                   "lib/bank_statement_parser/hsbc.rb",
                   "lib/bank_statement_parser/statement_record.rb",
                   "lib/bank_statement_parser/utils.rb"]
  s.executables << "bank_statement_to_yaml.rb"
  s.homepage    =
    "https://github.com/spdawson/bank_statement_parser"
  s.license     = "GPLv3"
end
