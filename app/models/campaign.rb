class Campaign < ApplicationRecord
  belongs_to :account
  belongs_to :user

  validates :name, presence: true

  enum campaign_type: { broadcast: 0, drip: 1, triggered: 2 }
  enum status: { draft: 0, active: 1, paused: 2, completed: 3 }

  scope :for_account, ->(account_id) { where(account_id: account_id) }
end
