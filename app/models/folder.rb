class Folder < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  has_many :items, dependent: :destroy

  include Slugifiable::InstanceMethods
  extend Slugifiable::ClassMethods

end
