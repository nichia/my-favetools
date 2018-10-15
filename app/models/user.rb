class User < ActiveRecord::Base
  has_many :folders, dependent: :destroy
  has_many :items, through: :folders
  has_many :categories, through: :folders

  # add 'bcrypt' to gemfile - set and authenticate against a BCrypt password (requires password_digest attribute).
  has_secure_password

  # Regex - (alphanumeric, underscore and dashes) @ (alphanumeric, underscore and dashes) . (alphabetic - 2 to 4)
  EMAIL_REGEX = /\A[A-Za-z0-9_-]+@[A-Za-z0-9_-]+.[A-Za-z]{2,4}\z/

  # Regex - alphanumberic, underscore, and dashes
  USERNAME_REGEX = /\A[A-Za-z0-9_-]+\z/

  validates :name,  presence: { message: "Username must be provided" },
                    length: { in: 4..10,
                      too_long: "Username too long, 10 characters is the maximum allowed",
                      too_short: "Username too short, 4 characters is the minimum allowed", },
                    uniqueness: { message: "Username already taken, please choose another.",
                                  case_sensitive: false },
                    format: { with: USERNAME_REGEX, message: "Username should contain alphanumeric, underscores and dashes only." }

  validates :email, presence: { message: "Email must be provided" },
                    uniqueness: { message: "Email already taken, please choose another.",
                                  case_sensitive: false },
                    confirmation: { case_sensitive: false },
                    format: { with: EMAIL_REGEX, message: "Email format should be jsmith@example.com" }

  validates :password, presence: { message: "Password must be provided" },
                      length: { in: 6..12, message: "Password length must be 6 to 12 characters" }

  include Slugifiable::InstanceMethods
  extend Slugifiable::ClassMethods

end
