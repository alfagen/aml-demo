class CopyOperatorsToUsers < ActiveRecord::Migration[5.2]
  def up
    AML::Operator.all.each do |operator|
      user = User.find_or_create_by!(email: operator.email, crypted_password: operator.crypted_password, salt: operator.salt)
      operator.update user_id: user.id
    end
  end

  def down
    AML::Operator.update_all user_id: nil
  end
end
