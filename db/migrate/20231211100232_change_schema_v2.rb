class ChangeSchemaV2 <  ActiveRecord::Migration[6.0]
def change

  create_table :trashes , comment: 'Stores deleted to-do items for potential recovery' do |t|
    
      
        
        t.datetime :deleted_at  
      
    
    t.timestamps null: false
  end


  create_table :dashboards , comment: 'Represents the users dashboard after successful sign in' do |t|
    
      
        
    t.timestamps null: false
  end


  create_table :authentication_tokens , comment: 'Stores authentication tokens for users' do |t|
    
      
        
        t.datetime :expires_at  
      
    
      
        
        t.string :token  
      
    
      
        
    t.timestamps null: false
  end

change_table_comment :todos, from: "Stores todo items created by users", to: "Stores to-do items for users"

  
    add_column :todos, :status, :integer , default: 0
  



  
  remove_column :todos, :description, :text
  add_column :todos, :description, :string


  add_reference :dashboards, :user, foreign_key: true


  add_reference :authentication_tokens, :user, foreign_key: true


end
end