module AccountsHelper
  def get_data(account)
    json = []

    json << account.get_usage

    json
  end
end
