class Tool < ActiveRecord::Base
  belongs_to :folder

  include Slugifiable::InstanceMethods
  extend Slugifiable::ClassMethods

  # render non-private tools
  #Tool.joins(:folder).where(folders: {privacy: false})
  #Tool.joins(:folder).where('folders.privacy = ?', false)
  #Tool.joins(:folder).where('folders.privacy = ?', false).where('folders.user_id != ?', 5).order('id DESC').count
  #find non-private tools that does not belong to current user order by latest tools
  #Tool.joins(:folder).where(folders: {privacy: false}).where.not(folders: {user_id: current_user.user_id}).order('id DESC').count

  #ActiveRecord::StatementInvalid: SQLite3::SQLException: ambiguous column name: id: SELECT tools.name FROM "tools" INNER JOIN "folders" ON "folders"."id" = "tools"."
  #Tool.select('tools.name').joins(:folder).where(folders: {privacy: false}).where.not(folders: {user_id: current_user.user_id}).order('id DESC').count

  def self.find_by_privacy_user(privacy, user_id)
    Tool.joins(:folder).where(folders: {privacy: privacy}).where.not(folders: {user_id: user_id}).order('id DESC')
  end

end
