module Slugifiable
  module InstanceMethods
    def slug
      self.name.gsub(" ", "-").downcase
    end
  end #-- InstanceMethods --
  
  module ClassMethods
    def find_by_slug(slug)
      self.all.find do |object|
        object.slug == slug
      end
    end
  end #-- ClassMethods --

end
