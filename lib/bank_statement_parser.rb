module BankStatementParser

  @@logger = Logger.new(STDERR)
  def self.logger
    @@logger
  end
  def self.logger=(logger)
    @@logger = logger
  end

end
