class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  attr_accessible :email, :password, :password_confirmation, :remember_me,
  				  :first_name, :last_name, :profile_name


  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :profile_name, presence: true,
                           uniqueness: true,
                           format: {
                            with: /\A[a-zA-Z\-\_]+\Z/,
                            message: "must be formatted correctly. No spaces!"
                           }
  has_many :statuses
  has_many :user_friendships
  has_many :friends, through: :user_friendships

  def full_name
  	first_name + " " + last_name
  end

  def gravatar_url
    stripped_email = email.strip
    downcase_email = stripped_email.downcase
    hash = Digest::MD5.hexdigest(downcase_email)

    "http://gravatar.com/avatar/#{hash}"
  end
end
