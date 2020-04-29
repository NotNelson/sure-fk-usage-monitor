class AccountsController < ApplicationController
  before_action :authenticate_user!

  def index
    @accounts = Account.where(user_id: current_user.id)
  end

  def show
    @account = Account.find(params[:id])
  end

  def new
    @account = Account.new
  end

  def create
    @account = current_user.accounts.new(account_params)
    @account.encrypt_password
    if @account.save
      redirect_to @account
    end
  end

  def edit
    @account = Account.find(params[:id])
  end

  def update
    @account = Account.find(params[:id])

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
end
