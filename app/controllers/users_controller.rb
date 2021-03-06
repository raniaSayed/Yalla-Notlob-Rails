# app/controllers/users_controller.rb
class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: %i[login register]
   # POST /register
    def register
      @user = User.create(user_params)
      puts @user
     if @user.save
      response = { message: 'success'}
      render json: response, status: :created 
     else
      render json: @user.errors, status: :bad
     end 
    end

    def login
      authenticate params[:email], params[:password]
    end

    def search
      @user  = User.find_by_email(params[:email])
      if !@user.nil? 
        render json: @user
      else
        render json: {message:"user not found"}
      end
    end

    def get_data
      render json: User.select("name, email").find($user_id)
    end
    

    def join_order
      if @order_user = OrderUser.where(user_id: $user_id, order_id: params[:order_id])
        .update_all(join: true) > 0
      render json: {message:"success"}
      else
        render json: {message:"unauthorized"}
      end
    end
  
    private
  
    def user_params
      params.permit(
        :name,
        :email,
        :password,
        :api_type,
        :api_token,
        :profile_id
      )
    end

    def authenticate(email, password)
      command = AuthenticateUser.call(email, password)
  
      if command.success?
        render json: {
          access_token: command.result,
          message: 'success'
        }
      else
        render json: { error: command.errors }, status: :unauthorized
      end
     end 
  end