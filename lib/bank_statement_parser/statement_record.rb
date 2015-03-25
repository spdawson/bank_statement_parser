module BankStatementParser

  # A bank statement record
  class StatementRecord
    attr_accessor :date, :type, :credit, :amount, :detail

    # Constructor
    def initialize date: nil, type: nil, credit: nil, amount: nil, detail: nil
      @date = date
      @type = type
      @credit = credit
      @amount = amount
      @detail = detail
    end

    # Stringify
    def to_s
      "%s:%s:%s:%f:%s" % [date, type, credit.to_s, amount, detail]
    end

    # Equality test
    def ==(other)
      super || (date == other.date &&
                type == other.type &&
                credit == other.credit &&
                amount == other.amount &&
                detail = other.detail)
    end
  end

end
