class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  extend Dragonfly::Model
  
  belongs_to :account, index: true
  belongs_to :group, index: true
  belongs_to :membership, index: true
  belongs_to :team, index: true
  belongs_to :post, index: true

  field :body, :type => String 
  field :title, :type => String
  field :file_uid, :type => String
  
  dragonfly_accessor :file  
  
  validates_presence_of :body
    
  has_many :comment_likes, :dependent => :destroy
  has_many :options, :dependent => :destroy
  has_many :read_receipts, :dependent => :destroy
  
  after_create do
    post.subscriptions.create account: account
  end

  has_many :notifications, as: :notifiable, dependent: :destroy
  after_create do
    if account
      notifications.create! :group => group, :type => 'commented'
    end
  end  
  
  after_create do
    pusher_client = Pusher::Client.new(app_id: ENV['PUSHER_APP_ID'], key: ENV['PUSHER_KEY'], secret: ENV['PUSHER_SECRET'], cluster: ENV['PUSHER_CLUSTER'], encrypted: true)
    pusher_client.trigger("post.#{post.id}", 'updated', {})
  end
  
  after_destroy do
    pusher_client = Pusher::Client.new(app_id: ENV['PUSHER_APP_ID'], key: ENV['PUSHER_KEY'], secret: ENV['PUSHER_SECRET'], cluster: ENV['PUSHER_CLUSTER'], encrypted: true)
    pusher_client.trigger("post.#{post.id}", 'updated', {})
  end  
    
  before_validation do
    self.team = self.post.team if self.post
    self.group = self.team.group if self.team
    self.membership = self.group.memberships.find_by(account: self.account) if self.group and self.account and !self.membership
  end    
  
  def first_in_post?
    !post or post.new_record? or post.comments.order('created_at asc').first.id == self.id
  end
  
  after_create do
    post.update_attribute(:updated_at, Time.now)
  end

  def self.admin_fields
    {
      :body => :text_area,
      :title => :text,
      :file => :file,
      :account_id => :lookup,
      :group_id => :lookup,
      :membership_id => :lookup,
      :team_id => :lookup,
      :post_id => :lookup
    }
  end
    
end
