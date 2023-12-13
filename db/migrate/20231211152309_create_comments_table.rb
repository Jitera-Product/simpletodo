class CreateCommentsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :comments, comment: 'Stores user comments on todos' do |t|
      t.text :content, comment: 'Content of the comment'
      t.references :todo, null: false, foreign_key: true, comment: 'Reference to the todo item'
      t.references :user, null: false, foreign_key: true, comment: 'Reference to the user who made the comment'

      t.timestamps null: false
    end
  end
end
