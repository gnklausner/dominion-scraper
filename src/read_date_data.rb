class ReadDateData
  attr_accessor :start_date, :end_date, :bill_due_date, :bill_amount, :usage

  def initialize(start_date="", end_date="", bill_due_date="", bill_amount="", usage="")
    @start_date = start_date
    @end_date = end_date
    @bill_due_date = bill_due_date
    @bill_amount = bill_amount
    @usage = usage
  end
end