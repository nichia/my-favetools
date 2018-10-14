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

    def find_by_slug_user(slug, user_id)
      self.all.find do |object|
        object.slug == slug && object.user_id == user_id
      end
    end
  end #-- ClassMethods --

end
