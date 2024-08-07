class PostComment < ApplicationRecord
  include Notifiable

  belongs_to :user
  belongs_to :recommend_place_post
  has_many :comment_favorites, dependent: :destroy

  has_one :notification, as: :notifiable, dependent: :destroy

  validates :content, presence: true, length: { maximum: 50 }

  def favorited_by?(user)
    comment_favorites.exists?(user_id: user.id)
  end

  after_create do
    create_notification(user_id: recommend_place_post.user_id)
  end

  def notification_message
    "投稿にコメントが届きました。"
  end

  def notification_path
    recommend_place_post_path(recommend_place_post.id)
  end
end
