require 'terminal-table'
require_relative './read_date_data'

class Scraper
  def self.InitializeReadDateMap(dates)
    read_date_map = {}
    dates.each do |date|
      read_date_map[date] = ReadDateData.new
    end
    
    return read_date_map
  end  

  def self.RecordReadingsByReadDate(read_date_map, dates, readings)
    for i in (0 .. dates.size - 1)
      start_date = (i == 0) ? "" : dates[i - 1]
      end_date = dates[i]
      reading = readings[i]
      read_date_map[end_date] = ReadDateData.new(start_date, end_date, "", "", reading)
    end

    return read_date_map
  end

  def self.RecordBillingByReadDate(read_date_map, read_dates, bill_due_dates, bill_amounts)
    for i in (0 .. read_dates.size - 1)
      read_date_map[read_dates[i]].bill_due_date = bill_due_dates[i]
      read_date_map[read_dates[i]].bill_amount = bill_amounts[i]
    end

    return read_date_map
  end

  def self.PrintTable(table, keys)
    rows = []
    keys.each do |key|
      v = table[key]
      rows.push [v.start_date, v.end_date, v.bill_due_date, v.bill_amount, v.usage]
    end
    table = Terminal::Table.new :headings => ["Start Date", "End Date", "Bill Due Date", "Bill Amount", "Usage (kWh)"], :rows => rows
    puts table
  end
end