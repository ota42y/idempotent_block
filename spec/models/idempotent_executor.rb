ActiveRecord::Schema.define do
  create_table :idempotent_executors do |t|
    t.integer :user_id, null: false
    t.integer :block_type, null: false
    t.string :signature, null: false

    t.index [:user_id, :block_type, :signature], unique: true, name: :unique_index

    t.timestamps null: false
  end
end

class IdempotentExecutor < ActiveRecord::Base
  include ::IdempotentBlock

  enum block_type: [:post_create]

  register_idempotent_column :user_id, :block_type, :signature
end
