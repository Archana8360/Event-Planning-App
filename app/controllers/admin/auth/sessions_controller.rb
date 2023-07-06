class Admin::Auth::SessionsController < ApplicationController
  
    def new
    end

    def create
      admin = User.find_by(email: params[:user][:email])

      if admin && admin.is_admin? && admin.valid_password?(params[:user][:password])
        sign_in(admin)
        redirect_to authenticated_root_path
      else
        redirect_to unauthenticated_root_path, notice:"Invalid email or password."
      end
    end
  
    def destroy
      Devise.sign_out_all_scopes ? sign_out : sign_out(:user)
      redirect_to unauthenticated_root_path
    end
  
   
  end
  