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

      # Grab the full text file content
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
