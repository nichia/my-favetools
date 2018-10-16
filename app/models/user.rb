class User < ActiveRecord::Base
  has_many :folders, dependent: :destroy
  has_many :items, through: :folders
  has_many :categories, through: :folders

  # add 'bcrypt' to gemfile - set and authenticate against a BCrypt password ( password_digest).
  has_secure_password

  EMAIL_REGEX = /\A
    [A-Za-z0-9_-]       # Must contain alphanumeric, underscore and dashes characters
    +@[A-Za-z0-9_-]     # Must follow by '@' and alphanumeric, underscore and dashes characters
    +.[A-Za-z]{2,4}\z   # Must follow by '.' and 2 to 4 alphanumeric characters
  /x

  USERNAME_REGEX = /\A[A-Za-z0-9_-]+\z/   # Must contain alphanumberic, underscore, and dashes characters

  PASSWORD_FORMAT = /\A
    (?=.{6,})          # Must contain 6 or more characters
    (?=.*\d)           # Must contain a digit
    (?=.*[a-z])        # Must contain a lower case character
    (?=.*[A-Z])        # Must contain an upper case character
    (?=.*[[:^alnum:]]) # Must contain a symbol [POSIX bracket expressions]
  /x

  validates :name,
    presence: { message: "Username must be provided" },
    length: { in: 3..12,
      too_long: "Username too long, (maximum is 12 characters)",
      too_short: "Username too short, (minimum is 3 characters)", },
    uniqueness: { case_sensitive: false },
    format: { with: USERNAME_REGEX, message: "Username must contain alphanumeric, underscores and dashes only" }

  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: EMAIL_REGEX, message: "format must be jsmith@example.com" }

  validates :password,
   presence: true,
   length: { in: 6..32 },
   format: { with: PASSWORD_FORMAT, message: "must contain a digit, symbol, upper and lower cases, and have 6 or more characters" },
   on: :create

  validates :password,
   allow_nil: true,
   length: { in: 6..32 },
   format: { with: PASSWORD_FORMAT, message: "must contain a digit, symbol, upper and lower cases, and have 6 or more characters" },
   on: :update

  include Slugifiable::InstanceMethods
  extend Slugifiable::ClassMethods

end
