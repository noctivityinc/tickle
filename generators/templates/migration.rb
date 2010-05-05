class ActsAsTicklishMigration < ActiveRecord::Migration
  def self.up
    create_table :tickles, :force => true do |t|
      t.column :ticklish_id, :integer
      t.column :ticklish_type, :string
      t.column :occurs_at, :datetime
      t.column :last_occured_at, :datetime
      t.column :username, :string
      t.column :occurs_until, :datetime
      t.column :occurrences, :integer, :default => 0 
      t.column :version, :integer, :default => 0
      t.column :created_at, :datetime
    end
    
    add_index :tickles, [:ticklish_id, :ticklish_type], :name => 'ticklish_index'
    add_index :tickles, [:occurs_at, :occurs_until], :name => 'event_start_end_index'
    add_index :tickles, :occurs_at  
  end

  def self.down
    drop_table :tickles
  end
end
