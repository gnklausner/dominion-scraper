require 'mechanize'
require 'nokogiri'
require_relative '../../src/dominion_scraper'

describe DominionScraper do
  valid_dates = [
    '10/08/2015', '11/06/2015', '12/10/2015', '01/11/2016', '02/10/2016', '03/10/2016', '04/11/2016', 
    '05/10/2016', '06/09/2016', '07/11/2016', '08/09/2016', '09/08/2016', '10/07/2016', '11/07/2016', 
    '12/09/2016', '01/10/2017', '02/09/2017', '03/10/2017', '04/10/2017'
  ]

  valid_readings = [
    '456', '269', '420', '490', '655', '524', '368', '308', '488', '774', 
    '702', '904', '572', '397', '485', '554', '492', '424', '363'
  ]

  valid_bill_due_dates = [
    "05/04/2017", "04/04/2017", "03/06/2017", "02/03/2017", "01/04/2017", "12/03/2016", "11/01/2016", 
    "10/03/2016", "09/02/2016", "08/03/2016", "07/05/2016", "06/03/2016", "05/04/2016", 
    "04/05/2016", "03/04/2016", "02/04/2016", "01/05/2016", "12/04/2015", "11/02/2015"
  ]

  valid_bill_amounts = [
    "$46.65", "$53.15", "$60.75", "$67.74", "$59.98", "$50.13", "$69.75", 
    "$107.65", "$83.92", "$94.15", "$62.18", "$41.41", "$47.72", "$65.12", 
    "$80.03", "$61.34", "$53.41", "$36.65", "$57.48"
  ]

  agent = Mechanize.new

  usage_path = File.expand_path('../html/usage.htm', File.dirname(__FILE__))
  usage_html= File.open(usage_path).read
  usage_page = Mechanize::Page.new(nil,{'content-type'=>'text/html'}, usage_html, nil, agent)

  billing_path = File.expand_path('../html/billing.htm', File.dirname(__FILE__))
  billing_html= File.open(billing_path).read
  billing_page = Mechanize::Page.new(nil,{'content-type'=>'text/html'}, billing_html, nil, agent)

  xdescribe "#Login" do
    # ToDo - Find a good way to test this.
  end

  describe "#GetUsageData" do
      dates, readings = DominionScraper.GetUsageData(usage_page)

    it "returns arrays of equal size" do
      expect(dates.size).to eq readings.size
    end

    it "returns an array of valid dates" do
      all_dates_are_valid = true
      dates.each do |date|
        begin
          Date.parse(date)
        rescue => ArgumentError
          all_dates_are_valid = false
        end
      end

      expect(dates).to eq valid_dates
      expect(all_dates_are_valid).to eq true
    end

    it "returns an array of valid kWh measurements" do
      expect(readings).to eq valid_readings
    end
  end

  describe "#ParseUsageData" do
    it "properly parses a string of '[[date, usage],[date,usage],...[date,usage]]'" do
      unparsed_string = "[[1491796800000,363],[1489122000000,424],[1486616400000,492],[1484024400000,554]," + 
        "[1481259600000,485],[1478494800000,397],[1475812800000,572],[1473307200000,904],[1470715200000,702]," + 
        "[1468209600000,774],[1465444800000,488],[1462852800000,308],[1460347200000,368],[1457586000000,524]," + 
        "[1455080400000,655],[1452488400000,490],[1449723600000,420],[1446786000000,269],[1444276800000,456]]"
      parsed_dates, parsed_readings = DominionScraper.ParseUsageData(unparsed_string)

      expect(parsed_dates).to eq valid_dates
      expect(parsed_readings).to eq valid_readings
    end
  end

  describe "#GetNextReadDate" do
    it "finds the next meter read date" do
      next_read_date = DominionScraper.GetNextReadDate(usage_page)

      expect(next_read_date).to eq "05/10/2017"
    end
  end

  describe "#GetBillingData" do
    read_dates, bill_due_dates, bill_amounts = DominionScraper.GetBillingData(billing_page)

    it "returns arrays of equal size" do
      expect(read_dates.size).to eq bill_due_dates.size
      expect(bill_due_dates.size).to eq bill_amounts.size
    end

    # ToDo - Try to find less contrived ways of testing this.
    it "returns a correct array of bill due dates" do
      expect(bill_due_dates).to eq valid_bill_due_dates
    end
    
    it "returns a correct array of bill amounts" do
      expect(bill_amounts).to eq valid_bill_amounts
    end
  end

  describe "#ParseBillingData" do
    billing_table_path = File.expand_path('../html/billing_table.htm', File.dirname(__FILE__))
    billing_table_html= File.open(billing_table_path).read
    billing_table = Nokogiri::HTML(billing_table_html)

    read_dates, bill_due_dates, bill_amounts = DominionScraper.ParseBillingData(billing_table)

    it "returns arrays of equal size" do
      expect(read_dates.size).to eq bill_due_dates.size
      expect(bill_due_dates.size).to eq bill_amounts.size
    end

    # ToDo - Try to find less contrived ways of testing this.
    it "returns a correct array of bill due dates" do
      expect(bill_due_dates).to eq valid_bill_due_dates
    end
    
    it "returns a correct array of bill amounts" do
      expect(bill_amounts).to eq valid_bill_amounts
    end
  end
end