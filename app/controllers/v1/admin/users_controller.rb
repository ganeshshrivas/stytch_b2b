module V1
  module Admin
    class UsersController < ApplicationController
      # NOTE: in real app protect this endpoint (API key / auth)
      def create
        op = CreateUserWithOrg.new.call(
          email: params.require(:email),
          first_name: params[:first_name],
          last_name: params[:last_name],
          org_name: params.require(:org_name),
          org_slug: params.require(:org_slug)
        )
        if op.success?
          render json: { user: op.value![:user], organization: op.value![:organization] }, status: :created
        else
          render json: { error: op.failure }, status: :unprocessable_entity
        end
      end
    end
  end
end