class CreateOrganizationMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.string :role

      t.timestamps
    end
    add_index :organization_memberships, [:user_id, :organization_id], unique: true, name: 'index_org_memberships_on_user_and_org'
  end
end
