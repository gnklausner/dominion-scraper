require_relative '../../src/scraper'
require_relative '../../src/read_date_data'

describe Scraper do
  dates = ["01/01/1999", "02/01/1999"]
  readings = ["9001", "1337"]
  bill_due_dates = ["02/03/1999", "03/04/1999"]
  bill_amounts = ["$99", "$88"]

  describe "#InitializeReadDateMap" do
    it "sets up a map with empty ReadDateData values" do
      read_date_map = Scraper.InitializeReadDateMap(dates)
      expect(read_date_map.length).to eq 2
      expect(read_date_map.key?(dates[0])).to eq true
      expect(read_date_map[dates[0]].end_date).to eq "" 
      expect(read_date_map.key?(dates[1])).to eq true
      expect(read_date_map[dates[1]].end_date).to eq ""
    end
  end

  describe "#RecordReadingsByReadDate" do
    it "returns a map of { end_date : ReadDateData } with end_date, start_date, and usage set" do
      result_map = { 
        dates[0] => ReadDateData.new,
        dates[1] => ReadDateData.new
      }
      result_map = Scraper.RecordReadingsByReadDate(result_map, dates, readings)

      expect(result_map[dates[0]].end_date).to eq dates[0]
      expect(result_map[dates[0]].usage).to eq readings[0]
      expect(result_map[dates[1]].start_date).to eq dates[0]
      expect(result_map[dates[1]].end_date).to eq dates[1]
      expect(result_map[dates[1]].usage).to eq readings[1]

      expect(result_map[dates[0]].start_date).to eq ""
      expect(result_map[dates[0]].bill_due_date).to eq ""
      expect(result_map[dates[0]].bill_amount).to eq ""
      expect(result_map[dates[1]].bill_due_date).to eq ""
      expect(result_map[dates[1]].bill_amount).to eq ""
    end
  end

  describe "#RecordBillingByReadDate" do
    it "returns a map of { end_date : ReadDateData } with bill_due_date and bill_amount set" do
      result_map = { 
        dates[0] => ReadDateData.new,
        dates[1] => ReadDateData.new
      }
      result_map = Scraper.RecordBillingByReadDate(result_map, dates, bill_due_dates, bill_amounts)

      expect(result_map[dates[0]].bill_due_date).to eq bill_due_dates[0]
      expect(result_map[dates[0]].bill_amount).to eq bill_amounts[0]
      expect(result_map[dates[1]].bill_due_date).to eq bill_due_dates[1]
      expect(result_map[dates[1]].bill_amount).to eq bill_amounts[1]

      expect(result_map[dates[0]].start_date).to eq ""
      expect(result_map[dates[0]].end_date).to eq ""
      expect(result_map[dates[0]].usage).to eq ""
      expect(result_map[dates[1]].start_date).to eq ""
      expect(result_map[dates[1]].end_date).to eq ""
      expect(result_map[dates[1]].usage).to eq ""
    end
  end

  xdescribe "#PrintTable" do
    # ToDo - Complete when necessary
  end
end