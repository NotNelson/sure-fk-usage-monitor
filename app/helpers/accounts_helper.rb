module AccountsHelper
  # Return a Json object with additional account data
  def get_data(account)
    account.get_usage
  end

  # Take the usage part of the Json data and turn it into a format that can be
  # used to generate a chart. TODO: this is quite esoteric, refactor one day.
  def parse_table_data(json)
    data = []
    json["daily"].each do |item|
      item = item.to_s.gsub('{', '').gsub('}', '')
      date = item[0..item.index('>')-2]
      usage = item[item.index('>')+1..item.length].gsub('"', '')
      data << [date, usage]
    end
    data
  end
end
