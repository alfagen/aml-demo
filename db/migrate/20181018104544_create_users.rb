class CreateUsers < ActiveRecord::Migration[5.2]
  def up
    create_table :users do |t|
      t.string :email, null: false
      t.string :crypted_password
      t.string :salt

      t.timestamps
    end

    add_reference :users, :aml_operator, foreign_key: true
    add_index :users, :email, unique: true

    AML::Operator.all.each do |operator|
      User.create!(email: operator.email, crypted_password: operator.crypted_password, salt: operator.salt, aml_operator_id: operator.id)
    end
  end

  def down
    drop_table :users
  end
end
