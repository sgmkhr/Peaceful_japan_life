class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :profile_image

  has_many :recommend_place_posts, dependent: :destroy
  has_many :post_comments, dependent: :destroy
  has_many :post_favorites, dependent: :destroy
  has_many :comment_favorites, dependent: :destroy

  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followings, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  has_many :post_view_counts, dependent: :destroy

  has_many :active_views, class_name: "ProfileViewCount", foreign_key: "viewer_id", dependent: :destroy
  has_many :passive_views, class_name: "ProfileViewCount", foreign_key: "viewed_id", dependent: :destroy
  has_many :profile_viewers, through: :passive_views, source: :viewer

  has_many :user_rooms
  has_many :chats
  has_many :rooms, through: :user_rooms

  has_many :notifications, dependent: :destroy

  has_many :group_users, dependent: :destroy
  has_many :group_comments, dependent: :destroy

  has_many :post_saves, dependent: :destroy
  has_many :saved_posts, through: :post_saves, source: :recommend_place_post

  scope :latest, -> { order(created_at: :desc) }
  scope :old, -> { order(created_at: :asc) }

  validates :name, presence: true
  validates :nick_name, presence: true, uniqueness: true
  validates :introduction, length: { maximum: 50 }
  validates :role, presence: true

  GUEST_USER_EMAIL = "guest@example.com"

  def self.guest
    find_or_create_by!(email: GUEST_USER_EMAIL) do |user|
      user.password = SecureRandom.urlsafe_base64
      user.name = "guestuser"
      user.nick_name = "guest_user"
      user.role = "begginer"
    end
  end

  def guest_user?
    email == GUEST_USER_EMAIL
  end

  def get_profile_image(width, height)
    unless profile_image.attached?
      file_path = Rails.root.join("app/assets/images/no_image.jpg")
      profile_image.attach(io: File.open(file_path), filename: "default-image.jpg", content_type: "image/jpeg")
    end
    profile_image.variant(resize_to_limit: [width, height]).processed
  end

  def get_role
    if self.role == "beginner"
      "初心者"
    elsif self.role == "intermediate"
      "中級者"
    else
      "ベテラン"
    end
  end

  def follow(user)
    active_relationships.create(followed_id: user.id)
  end

  def unfollow(user)
    active_relationships.find_by(followed_id: user.id).destroy
  end

  def following?(user)
    followings.include?(user)
  end

  def self.search_for(content, method, select_role)
    if method == "perfect"
      User.where(nick_name: content, role: select_role)
    else
      User.where(role: select_role).where("nick_name LIKE?", "%" + content + "%")
    end
  end
end
