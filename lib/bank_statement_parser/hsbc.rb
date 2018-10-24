# Copyright 2015-2018 Simon Dawson <spdawson@gmail.com>

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

require 'date'
require 'bank_statement_parser/base'
require 'bank_statement_parser/statement_record'
require 'bank_statement_parser/statement_record_types'
require 'bank_statement_parser/utils'
module BankStatementParser

  # Parser for HSBC bank statements
  class HSBC < Base

    # Handle the specified line
    #
    # Returns true if parsing should continue; false to terminate the parser
    def handle_line line

      # Re-encode line to ASCII
      line = Utils.ascii_filter(line)

      # Skip blank lines
      return true if line =~ /\A\s*\z/

      # Sanity checking
      raise "line contains TAB characters" if line =~ /\t/

      # Stop line
      if line =~ /\A\s+AER\s+EAR\s*\z/
        logger.debug { "Found stop line (2nd form)" }
        return false
      end
      if line =~ /\AStatements produced from \d{1,2} (?:#{MONTHS.join('|')}) \d{4} are available in PDF format\.\s*\z/
        logger.debug { "Found stop line (1st form)" }
        return false
      end

      # Look for sort code and account number lines, if we haven't found
      # one yet
      if sort_code.nil? && account_number.nil?
        if line =~ /(?:\A[A-Z][\w\s]+|,)\s+(?<sort_code>\d{2}-\d{2}-\d{2})\s+(?<account_number>\d{8})(?:\s*|\s+\d+)\z/
          logger.debug { "Found sort code and account number" }
          self.sort_code = Regexp.last_match(:sort_code)
          self.account_number = Regexp.last_match(:account_number)

          if line =~ /^\s*(?<account_name>.+)\s+(\d{2}-\d{2}-\d{2})\s+(\d{8})\s+(\d+)\s*$/
            # New-style metadata line, first field is account [holder] name
            self.name = Regexp.last_match(:account_name).strip
            logger.debug { "Found account holder name (2nd form): #{self.name}" }
          elsif line =~ /^\s*(?<account_name>.+)\s*,\s+(\d{2}-\d{2}-\d{2})\s+(\d{8})\s*$/
            # Old-style metadata line, first field is account [holder] name
            self.name = Regexp.last_match(:account_name).strip
            logger.debug { "Found account holder name (1st form): #{self.name}" }
          end
        end
      end

      # Look for statement date lines, if we haven't found one yet
      if statement_date.nil?
        if line =~ /\A\s*(?<statement_date>\d{2} (?:#{MONTHS.map{|m| m[0,3]}.join('|')}) \d{4})\s*\z/
          logger.debug { "Found statement date (1st form)" }
          @statement_format = StatementFormat::FORMAT_1ST

          # Parse statement date
          date_string = Regexp.last_match(:statement_date)
          self.statement_date = Date.parse(date_string)
        elsif line =~ /\A(?<date_range_start>\d+\s+(?:#{MONTHS.join('|')})(?:\s+\d{4})?)\s+to\s+(?<date_range_end>\d+\s+(?:#{MONTHS.join('|')})\s+\d{4})\b/
          logger.debug { "Found statement date (2nd form)" }
          @statement_format = StatementFormat::FORMAT_2ND

          date_range_start = Regexp.last_match(:date_range_start)
          date_range_end = Regexp.last_match(:date_range_end)
          logger.debug { "Found statement date range #{date_range_start}-#{date_range_end}" }

          # Parse range end date
          self.statement_date = Date.parse(date_range_end)
        end
      end

      if !sort_code.nil? && !account_number.nil? && !statement_date.nil?

        # Look for statement records proper
        headings = nil
        case @statement_format
        when StatementFormat::FORMAT_UNKNOWN
          raise "Failed to detect statement format before start of records"
        when StatementFormat::FORMAT_1ST
          headings = COLUMN_HEADINGS_1ST
        when StatementFormat::FORMAT_2ND
          headings = COLUMN_HEADINGS_2ND
        end
        logger.debug { "Parsing potential record line (format #{@statement_format}): #{line}" }
        parse_record_line_format(line, headings)

      end

      return true
    end

    private

    TYPES = {
      'ATM' => StatementRecordTypes::ATM,
      'BP' => StatementRecordTypes::BILL_PAYMENT,
      'CHQ' => StatementRecordTypes::CHEQUE,
      'CIR' => StatementRecordTypes::CIRRUS,
      'CR' => StatementRecordTypes::CREDIT,
      'DD' => StatementRecordTypes::DIRECT_DEBIT,
      'DIV' => StatementRecordTypes::DIVIDEND,
      'DR' => StatementRecordTypes::DEBIT,
      'MAE' => StatementRecordTypes::MAESTRO,
      'PIM' => StatementRecordTypes::PAYING_IN_MACHINE,
      'SO' => StatementRecordTypes::STANDING_ORDER,
      'TFR' => StatementRecordTypes::TRANSFER,
      'VIS' => StatementRecordTypes::VISA,
      ')))' => StatementRecordTypes::CONTACTLESS,
      'IAP' => StatementRecordTypes::INTERNET_ACCESS_PAYMENT,
    }

    MONTHS = Date::MONTHNAMES[1..12]

    # N.B. Unicode pound symbol deleted from brackets in balance column heading
    COLUMN_HEADINGS_1ST = ["Date",
                           "Type\\s+Description",
                           "Paid out",
                           "Paid in",
                           "Balance \\(\\)"]

    COLUMN_HEADINGS_2ND = ["Date",
                           "Pay\\s?m\\s?e\\s?nt t\\s?y\\s?p\\s?e and d\\s?e\\s?t\\s?ails",
                           "Paid o\\s?ut",
                           "Paid in",
                           "Balance"]

    # Enumerate statement formats
    module StatementFormat
      FORMAT_UNKNOWN = 0
      FORMAT_1ST = 1 # "old" style, browser-printed PDF
      FORMAT_2ND = 2 # "new", pre-formatted PDF
    end

    # Reset the parser
    def reset
      super

      @statement_format = StatementFormat::FORMAT_UNKNOWN

      # Somewhere to cache the most-recent statement record date
      @cached_statement_date = nil

      # Somewhere to cached the most-recent statement record type
      @cached_payment_type = nil

      # Somewhere to cache details for the ongoing statement record
      @cached_details = []

      # Somewhere to cache column alignments
      @cols = []

      # Flag to temporarily pause the parser
      @parser_paused = false
    end

    # Fix the year of the specified record date
    #
    # Returns the record date, with the year fixed
    def fix_record_date_year record_date
      # Sanity checking
      if Date.today.year != record_date.year
        logger.info { "No need to fix year for statement record date" }
        return record_date
      end

      # The date we have parsed will have the year set to the current year.
      #
      # We need to figure out the correct year, from the statement date.
      raise "No statement date" unless statement_date
      record_date = Date.new(statement_date.year,
                             record_date.month,
                             record_date.day)
      logger.debug { "record date #{record_date}" }
      if statement_date.month != record_date.month
        logger.debug { "record month differs from statement month" }
        if 1 == statement_date.month
          # Assume that the statement crosses a year boundary: the record
          # must be from the end of the previous year
          raise "Expected a record from December" unless
            12 == record_date.month
          record_date = record_date.prev_year
        end
      end

      record_date
    end

    # If the specified line is a headings line, use it to update our column
    # alignments
    #
    # Returns true if column alignments were updated; false otherwise
    def update_columns line, headings
      # Look for lines that allow us to match column alignments
      raise "Expected a five-column layout" unless 5 == headings.size

      # Build a regexp for matching the column header line
      column_heading_regexp_str = '\A'
      headings.each_with_index do |item,index|
        pre_space_match = ''
        post_space_quantifier = '{2,}'
        if 0 == index
          pre_space_match = '\s*'
        elsif (headings.length - 1) == index
          post_space_quantifier = '*'
        end
        column_heading_regexp_str +=
          '(?<col' + index.to_s + '>' + pre_space_match + item + '\s' + post_space_quantifier + ')'
      end
      column_heading_regexp_str += '\z'
      column_heading_regexp = Regexp.new(column_heading_regexp_str)

      if line =~ column_heading_regexp
        if @cols.empty?
          logger.debug { "Setting column alignments from line #{line}" }
        else
          logger.debug { "Updating column alignments from line #{line}" }
        end
        (0...headings.size).each do |i|
          str_i = "col" + i.to_s
          sym_i = str_i.to_sym
          @cols[i] = Regexp.last_match.offset(sym_i)[0]
        end

        return true
      end

      return false
    end

    # Split the specified line into an array of column fragments
    def get_column_fragments line
      col_fragments = []

      @cols.reverse.each_with_index do |i,index|
        # We need to be flexible here, because the columns can (and do)
        # fail to line up with the heading alignments
        #
        # Check whether the supposed column boundary has whitespace on
        # at least one side:
        #
        # * If so, then this is a correct column boundary
        # * If not, then (somewhat arbitrarily, based on cases that have
        #   been seen) opt to move the column left until we hit whitespace
        if (i > 0) && (i < line.length)
          char_before_boundary = line[i-1]
          char_after_boundary = line[i]
          unless char_before_boundary =~ /\A\s\z/ ||
              char_after_boundary =~ /\A\s\z/
            logger.warn { "Column boundary failure: #{char_before_boundary}|#{char_after_boundary}" }

            # Shift down until we hit whitespace before the boundary
            boundary_limit =
              ((index + 1) < @cols.reverse.size) ? @cols.reverse[index + 1] : -1
            logger.debug { "Boundary adjust limit #{boundary_limit}" }
            new_boundary = i
            while new_boundary > boundary_limit
              left = line[new_boundary]
              if left =~ /\A\s\z/
                logger.debug { "Adjusting column boundary from #{i} to #{new_boundary}" }
                i = new_boundary
                break
              end
              new_boundary -= 1
            end

            raise "Failed to adjust column boundary" if 0 == new_boundary

          end
        end

        fragment_i = line[i...(line.length)]
        unless fragment_i.nil?
          fragment_i.strip!
          if fragment_i.empty?
            fragment_i = nil
          end
        end
        col_fragments.unshift(fragment_i)
        line = line[0...i]
      end

      return col_fragments
    end

    # Parse the specified line, looking for records
    def parse_record_line_format line, headings

      if update_columns(line, headings)
        if @parser_paused
          logger.debug { "Resuming parser: set/updated columns" }
          @parser_paused = false
        end
        return
      end

      # Skip known "noise" lines
      return if line =~ /\A\s*A\s*\z/

      return if @cols.empty?

      return if @parser_paused

      col_fragments = get_column_fragments(line)

      # N.B. Detect and fix up failed column splitting
      date_string = col_fragments[0]
      unless date_string.nil?
        if date_string =~ /(?<date_proper>.+)\s+(?<spurious_tail>[A-Z]+)\z/
          date_proper = Regexp.last_match(:date_proper)
          spurious_tail = Regexp.last_match(:spurious_tail)
          logger.warn { "Must fix date string #{date_string}|#{date_proper}|#{spurious_tail}" }
          col_fragments[0] = date_proper
          col_fragments[1] = spurious_tail + " " + col_fragments[1]
        end
      end

      date_string = col_fragments[0]
      unless date_string.nil?
        begin
          @cached_statement_date = Date.parse(date_string)
          @cached_statement_date =
            fix_record_date_year(@cached_statement_date)
        rescue ArgumentError => e
          raise "Failed to parse date/time '#{date_string}': #{e}"
        end
      end

      payment_type_and_details = col_fragments[1]

      if payment_type_and_details =~ /\ABALANCE CARRIED FORWARD\z/i
        cb = col_fragments[4]
        unless cb.nil?
          if cb =~ /\s+D\z/
            # Overdrawn; remove suffix and make negative
            cb = '-' + cb.sub(/\s+D\z/, '')
          end
          cb = cb.delete(",").to_f
          self.closing_balance = cb
          logger.debug { "Found potential closing balance: #{cb}" }
        end
        logger.debug { "Pausing parser" }
        @parser_paused = true
        return
      elsif payment_type_and_details =~ /\ABALANCE BROUGHT FORWARD(\s+\.)?\z/i
        if opening_balance.nil?
          ob = col_fragments[4]
          unless ob.nil?
            if ob =~ /\s+D\z/
              # Overdrawn; remove suffix and make negative
              ob = '-' + ob.sub(/\s+D\z/, '')
            end
            ob = ob.delete(",").to_f
            self.opening_balance = ob
            logger.debug { "Found probable opening balance: #{ob}" }
          end
        end
        if @parser_paused
          logger.debug { "Resuming parser" }
          @parser_paused = false
        else
          logger.debug { "Skipping parser resume line" }
        end
        return
      end
      if @parser_paused
        logger.debug { "Skipping line: parser paused" }
        return
      end

      payment_details = nil
      if payment_type_and_details =~ /\A(?<payment_type>#{TYPES.keys.map{ |t| Regexp.quote(t) }.join('|')})\s+(?<payment_details>.*)\z/
        logger.debug { "Found the start of a record (group)" }
        @cached_payment_type = Regexp.last_match(:payment_type)
        payment_details = Regexp.last_match(:payment_details)
      else
        payment_details = payment_type_and_details
      end
      @cached_details << payment_details

      paid_out = col_fragments[2]
      paid_in = col_fragments[3]
      paid_out.delete!(",") unless paid_out.nil?
      paid_in.delete!(",") unless paid_in.nil?
      balance = col_fragments[4]
      unless balance.nil?
        balance = balance.delete(",").to_f
      end

      if !paid_out.nil? || !paid_in.nil?
        logger.debug { "Found the end of a record (group)" }
        full_details = @cached_details.join("\n")

        record_credit = !paid_in.nil?
        record_amount = record_credit ? paid_in.to_f : paid_out.to_f

        # Create statement record
        record = StatementRecord.new(date: @cached_statement_date,
                                     type: @cached_payment_type,
                                     record_type: TYPES[@cached_payment_type],
                                     credit: record_credit,
                                     amount: record_amount,
                                     detail: full_details,
                                     balance: balance)
        logger.debug { "Created statement record: #{record}" }
        add_record record

        @cached_payment_type = nil
        @cached_details = []
      end

    end

  end
end
