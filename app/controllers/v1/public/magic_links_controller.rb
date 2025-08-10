
module V1
  module Public
    class MagicLinksController < ApplicationController
      # POST /public/magic_links  { email: "", organization_slug: optional }
      def create
        email = params.require(:email).downcase.strip
        user = User.find_by(email: email)

        unless user
          # If user does NOT exist locally — check if Stytch has a member for this email in any of our orgs.
          stytch =Stytch::B2bClient.new
          orgs = Organization.where.not(stytch_organization_id: nil)
          orgs.each do |org|
            begin
              resp = stytch.get_member(organization_id: org.stytch_organization_id, email: email)
              member_id = resp['member_id'] || resp.dig('member','member_id')
              if member_id
                # delete dangling member
                stytch.delete_member(organization_id: org.stytch_organization_id, member_id: member_id)
                Rails.logger.info("Deleted dangling Stytch member #{member_id} for #{email} in org #{org.slug}")
              end
            rescue => e
              # ignore 404 / not found (means member not present in that org)
            end
          end

          return render json: { error: 'User not found' }, status: :not_found
        end

        # If user belongs to multiple organizations, require organization_slug param
        if params[:organization_slug].present?
          org = user.organizations.find_by(slug: params[:organization_slug])
          return render json: { error: 'Org mismatch' }, status: :unprocessable_entity unless org
        else
          # if user has exactly 1 org, pick it; otherwise force client to pass organization_slug
          if user.organizations.count == 1
            org = user.organizations.first
          else
            return render json: { error: 'Multiple organizations associated; provide organization_slug' }, status: :unprocessable_entity
          end
        end
        stytch = Stytch::B2bClient.new
        stytch.send_magic_link(organization_id: org.stytch_organization_id, email: user.email)
        render json: { status: 'magic_link_sent' }, status: :ok
      end

      # POST /public/magic_links/authenticate
      def authenticate
        token = params.require(:token)
        stytch = Stytch::B2bClient.new

        begin
          resp = stytch.authenticate_magic_link(magic_links_token: token)
        rescue => e
          return render json: { error: 'Invalid or expired token' }, status: :unauthorized
        end

        # resp should include member info & organization
        # Extract canonical email and member_id / organization_id
        member = resp['member'] || resp['member_id'] ? resp['member'] : nil
        email = resp.dig('member', 'email_address') || resp['email_address'] || resp.dig('member','email')
        member_id = resp['member_id'] || resp.dig('member', 'member_id')
        org_id = resp.dig('organization','organization_id') || resp.dig('organization','id') || resp.dig('member','organization_id')

        # Find local user by email
        user = User.find_by(email: email)
        if user
          # Successful login — create your own session/jwt and return it
          # (Here we'll return a simple response for demo)
          render json: { message: 'Authenticated', user: { id: user.id, email: user.email } }, status: :ok
        else
          # Not allowed: user not in our DB. If Stytch said member exists (dangling), delete it.
          if member_id && org_id
            begin
              stytch.delete_member(organization_id: org_id, member_id: member_id)
              Rails.logger.info("Deleted dangling stytch member #{member_id} while blocking login for #{email}")
            rescue => e
              Rails.logger.error("Failed to delete dangling stytch member: #{e.message}")
            end
          end
          render json: { error: 'Not allowed' }, status: :unauthorized
        end
      end
    end
  end
end
