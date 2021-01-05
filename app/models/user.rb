class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  validates :name, presence: true
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_many :likes, dependent: :destroy
  has_many :like_posts, through: :likes, source: :post

  has_many :followee_follows, foreign_key: :follower_id, class_name: "Follow", dependent: :destroy
  has_many :followees, through: :followee_follows, source: :followee

  has_many :follower_follows, foreign_key: :followee_id, class_name: "Follow", dependent: :destroy
  has_many :followers, through: :follower_follows, source: :follower
  
  after_create :assign_default_role

  def assign_default_role
    self.add_role(:standard) if self.roles.blank?
  end


  def toggle_follow(user)
    if self.followers.include?(user)
      self.followers.delete(user)
    else
      self.followers.push(user)
    end
  end

end
