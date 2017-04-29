require_relative '../../src/read_date_data'

describe ReadDateData do
  describe "#initialize" do
    it "sets the input to its properties" do
      read_date_date = ReadDateData.new("01/01/1999", "02/01/1999", "03/01/1999", "$99", "9001")
      expect(read_date_date.start_date).to eq "01/01/1999"
      expect(read_date_date.end_date).to eq "02/01/1999"
      expect(read_date_date.bill_due_date).to eq "03/01/1999"
      expect(read_date_date.bill_amount).to eq "$99"
      expect(read_date_date.usage).to eq "9001"
    end

    it "sets sane defaults (i.e. blank)" do
      read_date_date = ReadDateData.new
      expect(read_date_date.start_date).to eq ""
      expect(read_date_date.end_date).to eq ""
      expect(read_date_date.bill_due_date).to eq ""
      expect(read_date_date.bill_amount).to eq ""
      expect(read_date_date.usage).to eq ""
    end
  end
end