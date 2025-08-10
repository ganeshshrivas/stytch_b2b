# app/operations/create_user_with_org.rb
require 'dry/operation'
require 'dry/monads'

class CreateUserWithOrg
  include Dry::Monads[:result]

  def call(input)
    input = input.transform_keys(&:to_sym)

    return Failure(:invalid_input) unless valid_input?(input)

    persist(input)
  end

  private

  def valid_input?(input)
    input[:email].present? && input[:org_name].present? && input[:org_slug].present?
  end

  def persist(input)
    stytch = Stytch::B2bClient.new
    user = nil
    org = nil
    error = nil

    ActiveRecord::Base.transaction do
      begin
        org = Organization.create!(name: input[:org_name], slug: input[:org_slug])
        user = User.create!(
          email: input[:email].downcase.strip,
          first_name: input[:first_name],
          last_name: input[:last_name]
        )

        # Create organization in Stytch
        stytch_org_resp = stytch.create_organization(name: org.name, slug: org.slug)
        unless stytch_org_resp.dig('status_code') == 200
          raise "Failed to create organization in Stytch: #{stytch_org_resp.inspect}"
        end

        stytch_org_id = stytch_org_resp.dig('organization', 'organization_id')
        raise "Missing stytch_org_id" unless stytch_org_id

        org.update!(stytch_organization_id: stytch_org_id)

        # Create member in Stytch
        name = [ user.first_name, user.last_name ].compact.join(' ').presence

        member_resp = stytch.create_member(
          organization_id: stytch_org_id,
          email: user.email,
          name: name,
          external_id: user.id.to_s
        )

        unless member_resp.dig('status_code') == 200
          raise "Failed to create member in Stytch: #{member_resp.inspect}"
        end

        stytch_member_id = member_resp.dig('member', 'member_id')
        raise "Missing stytch_member_id" unless stytch_member_id

        user.update!(stytch_member_id: stytch_member_id)

        OrganizationMembership.create!(user: user, organization: org, role: 'owner')
      rescue => e
        error = e
        raise ActiveRecord::Rollback
      end
    end
    if error.present?
      Failure(error)
    else
      Success(user: user, organization: org)
    end
  end
end
