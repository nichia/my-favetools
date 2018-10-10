class Tool < ActiveRecord::Base
  belongs_to :folder

  include Slugifiable::InstanceMethods
  extend Slugifiable::ClassMethods
end
