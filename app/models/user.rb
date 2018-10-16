class User < ActiveRecord::Base
  has_many :folders, dependent: :destroy
  has_many :items, through: :folders
  has_many :categories, through: :folders

  # add 'bcrypt' to gemfile - set and authenticate against a BCrypt password ( password_digest).
  has_secure_password

  # Regex - (alphanumeric, underscore and dashes) @ (alphanumeric, underscore and dashes) . (alphabetic - 2 to 4)
  EMAIL_REGEX = /\A[A-Za-z0-9_-]+@[A-Za-z0-9_-]+.[A-Za-z]{2,4}\z/

  # Regex - alphanumberic, underscore, and dashes
  USERNAME_REGEX = /\A[A-Za-z0-9_-]+\z/

  validates :name,  presence: { message: "Username must be provided" },
                    length: { in: 4..12,
                      too_long: "Username too long, (maximum is 12 characters)",
                      too_short: "Username too short, (minimum is 4 characters)", },
                    uniqueness: { case_sensitive: false },
                    format: { with: USERNAME_REGEX, message: "Username should contain alphanumeric, underscores and dashes only." }

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    confirmation: { case_sensitive: false },
                    format: { with: EMAIL_REGEX, message: "format should be jsmith@example.com" }

  validates :password, presence: true,
                      length: { in: 6..12}

  include Slugifiable::InstanceMethods
  extend Slugifiable::ClassMethods

end
