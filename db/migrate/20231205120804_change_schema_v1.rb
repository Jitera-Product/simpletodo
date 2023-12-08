class ChangeSchemaV1 <  ActiveRecord::Migration[6.0]
def change

  create_table :users , comment: 'Table to store user information' do |t|
    
      
        
        t.string :session_token  
      
    
      
        
        t.string :password  
      
    
      
        
        t.string :email  
      
    
    t.timestamps null: false
  end


  create_table :dashboards , comment: 'Table to store user's dashboard data' do |t|
    
      
        
        t.text :data  
      
    
    t.timestamps null: false
  end


end
end