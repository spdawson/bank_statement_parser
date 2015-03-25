require 'logger'
require 'bank_statement_parser/hsbc'
require 'bank_statement_parser/statement_record'
module BankStatementParser

  @@logger = Logger.new(STDERR)
  def self.logger
    @@logger
  end
  def self.logger=(logger)
    @@logger = logger
  end

end
