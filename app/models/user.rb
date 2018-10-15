class User < ActiveRecord::Base
  has_many :folders, dependent: :destroy
  has_many :items, through: :folders
  has_many :categories, through: :folders

  has_secure_password

  validates :username, uniqueness: { case_sensitive: false }
  validates :email, uniqueness: { case_sensitive: false }
  
  include Slugifiable::InstanceMethods
  extend Slugifiable::ClassMethods
end
