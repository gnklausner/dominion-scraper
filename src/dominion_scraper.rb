require 'mechanize'
require 'nokogiri'
require_relative './scraper.rb'

class DominionScraper < Scraper
  def self.Login(agent, domain, user_name, password)
    login_page  = agent.get(domain)
    form = login_page.form_with :name => "Login"

    form['USER'] = user_name
    form['PASSWORD'] = password

    next_page = form.submit

    return next_page
  end

  def self.GetUsageData(usage_page)
    usage_data_field = usage_page.at("//input[@id = 'UsageDataArrHdn']")

    dates, readings = ParseUsageData(usage_data_field.attributes["value"].value)

    return [dates, readings]
  end

  def self.ParseUsageData(input_string)
    # Input string is of the form "[[date, usage],[date,usage],...[date,usage]]"
    stripped_string = input_string.tr("[]", "") # date,usage,date,usage,...date,usage
    split_array = stripped_string.split(",")

    dates = split_array.values_at(* split_array.each_index.select {|i| i.even?} )
    dates.map! {|date| Time.at(date.to_i / 1000).strftime("%m/%d/%Y")}

    readings = split_array.values_at(* split_array.each_index.select {|i| i.odd?} )

    # Put in ascending order
    dates.reverse!
    readings.reverse!

    return [dates, readings]
  end

  def self.GetNextReadDate(usage_page)
    stripped_date = usage_page.at("//div[@id='homepageContent']//div[13]//div[1]//p").text.strip

    return DateTime.strptime(stripped_date, '%B %d, %Y').strftime("%m/%d/%Y")
  end

  def self.GetBillingData(billing_page)
    billing_page_body = Nokogiri::HTML(billing_page.body)
    billing_table = billing_page_body.css('table#billingAndPaymentsTable')
    read_dates, bill_due_dates, bill_amounts = ParseBillingData(billing_table)

    return [read_dates, bill_due_dates, bill_amounts]
  end

  def self.ParseBillingData(billing_table)
    table_width = billing_table.css('table th').size
    table_data_height = billing_table.css('table tr').size - 1 # There is a <tr> around the headers
    table_data_array = billing_table.css('table td')

    read_dates = []
    bill_amounts = []
    bill_due_dates = []
    for i in (0..(table_data_height - 1))
      read_date_index = 0 + (i * table_width)
      bill_amount_index = 1 + (i * table_width)
      due_date_index = 2 + (i * table_width)

      read_date = table_data_array[read_date_index].text.strip
      bill_due_date = table_data_array[due_date_index].text.strip
      bill_amount = table_data_array[bill_amount_index].text.strip

      if not bill_due_date == ""
        read_dates.push(read_date)
        bill_due_dates.push(bill_due_date)
        bill_amounts.push(bill_amount)
      end
    end

    return [read_dates, bill_due_dates, bill_amounts]
  end
end