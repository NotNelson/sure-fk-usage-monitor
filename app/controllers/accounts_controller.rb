class AccountsController < ApplicationController
  before_action :authenticate_user!

  def index
    @accounts = current_user.accounts.all
  end

  def show
    @account = current_account
  end

  def new
    @account = Account.new
  end

  def create
    @account = current_account
    @account.encrypt_password
    if @account.validate_account
      if @account.save
        redirect_to @account
      end
    end
  end

  def edit
    @account = current_account
  end

  def update
    @account = current_account

    if @account.update(account_params)
      @account.encrypt_password
      if @account.save
        redirect_to @account
      end
    end
  end

  def destroy
    @account = Account.find(params[:id])
    @account.destroy

    redirect_to accounts_path
  end

  private
  def account_params
    params.require(:account).permit(:user_id, :username, :password)
  end

  def current_account
    current_user.accounts.find(params[:id])
  end
end
