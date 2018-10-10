class User < ActiveRecord::Base
  has_many :folders, dependent: :destroy
  has_many :tools, through: :folders
  has_many :categories, through: :folders

  has_secure_password

  include Slugifiable::InstanceMethods
  extend Slugifiable::ClassMethods
end
