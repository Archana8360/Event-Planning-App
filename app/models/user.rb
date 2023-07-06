class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  has_one :profile, foreign_key: 'user_id', dependent: :destroy

  has_many :events
  has_many :favourite_events
  has_many :user_followers
  has_many :reports

  enum status: {
  inactive: 0,
  active: 1,
  unverified: 2,
  verified: 3,
  suspended: 4
  }
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: self
  
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }

  def jwt_payload
  super
  end
  end