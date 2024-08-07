class Chat < ApplicationRecord
  include Notifiable

  belongs_to :user
  belongs_to :room

  has_one :notification, as: :notifiable, dependent: :destroy

  validates :message, presence: true, length: { maximum: 140 }

  after_create do
    room.user_rooms.each do |user_room|
      if user_room.user_id != user.id
        create_notification(user_id: user_room.user_id)
      end
    end
  end

  def notification_message
    "新しくチャットが届きました。"
  end

  def notification_path
    chat_path(user)
  end
end
