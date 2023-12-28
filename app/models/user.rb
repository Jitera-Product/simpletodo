class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
  # end for validations

  # relationships
  has_many :folders, foreign_key: 'user_id', dependent: :destroy
  # end for relationships

  class << self
    # custom methods
  end

  # custom instance methods
end
