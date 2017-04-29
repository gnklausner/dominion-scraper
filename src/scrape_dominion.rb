require 'mechanize'
require 'io/console'
require_relative './dominion_scraper'

print "User Name: "
USER_NAME = STDIN.gets.chomp

print "Password: "
PASSWORD = STDIN.noecho(&:gets).chomp
puts '' # Fun pitfall. Putting a print here causes the password to show.

#############################
# Login
#############################
agent = Mechanize.new
usage_page = DominionScraper.Login(agent, "https://mya.dom.com/", USER_NAME, PASSWORD)

#############################
# Get Usage Data
#############################
dates, readings = DominionScraper.GetUsageData(usage_page)

next_read_date = DominionScraper.GetNextReadDate(usage_page) # This is the end_date for the last read date
dates.push(next_read_date)

read_date_map = DominionScraper.InitializeReadDateMap(dates)

read_date_map = DominionScraper.RecordReadingsByReadDate(read_date_map, dates, readings)

#############################
# Get Bill Date and Amount
#############################
parameters = {
  "statementType": 2,
  "startMonth": dates.first.split("/")[0],
  "startYear": dates.first.split("/")[2],
  "endMonth": dates.last.split("/")[0],
  "endYear": dates.last.split("/")[2]
}
billing_page = agent.get("https://mya.dom.com/Usage/ViewPastUsage", parameters)

read_dates, bill_due_dates, bill_amounts = DominionScraper.GetBillingData(billing_page)

read_date_map = DominionScraper.RecordBillingByReadDate(read_date_map, read_dates, bill_due_dates, bill_amounts)

#############################
# Print Table
#############################
DominionScraper.PrintTable(read_date_map, dates.reverse) # Print in descending order