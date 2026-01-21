class AddUserToPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :posts, :user, null: true, foreign_key: true

    reversible do |dir|
      dir.up do
        Post.reset_column_information
        User.reset_column_information

        default_user = User.order(admin: :desc, created_at: :asc).first
        unless default_user
          default_user = User.create!(
            email: "admin@example.com",
            password: "password123",
            password_confirmation: "password123",
            admin: true
          )
        end

        Post.where(user_id: nil).update_all(user_id: default_user.id)
      end
    end

    change_column_null :posts, :user_id, false
  end
end
