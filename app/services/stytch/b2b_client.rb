# app/services/stytch/b2b_client.rb
require 'stytch'
module Stytch
  class B2bClient
    def initialize
      @client = StytchB2B::Client.new(
        project_id: ENV.fetch('STYTCH_PROJECT_ID'),
        secret: ENV.fetch('STYTCH_SECRET')
      )
    end

    # Create organization in Stytch
    def create_organization(name:, slug:)
      @client.organizations.create(organization_name: name, organization_slug: slug)
    end

    # Create member in a given Stytch organization
    def create_member(organization_id:, email:, name: nil, external_id: nil)
      @client.organizations.members.create(organization_id: organization_id, email_address: email, external_id: external_id)
    end

    # Send an email magic link (B2B): login_or_signup sends login link
    def send_magic_link(organization_id:, email:)
      @client.magic_links.email.login_or_signup(
        organization_id: organization_id,
        email_address: email
      )
    end

    # Authenticate magic-link token (B2B)
    # NOTE: B2B authenticate expects magic_links_token param in docs
    def authenticate_magic_link(magic_links_token:)
      @client.magic_links.authenticate(magic_links_token: magic_links_token)
    end

    # Get member (organization + email)
    def get_member(organization_id:, email:)
      @client.organizations.members.get(organization_id: organization_id, email_address: email)
    end

    # Delete a member
    def delete_member(organization_id:, member_id:)
      @client.organizations.members.delete(organization_id: organization_id, member_id: member_id)
    end
  end
end
