# frozen_string_literal: true

class ClientDocument < ApplicationRecord
  extend Enumerize
  include Workflow
  include Authority::Abilities
  mount_uploader :image, FileUploader

  enumerize :workflow_state, in: %w[pending accepted rejected], scope: true

  scope :ordered, -> { order 'id desc' }

  belongs_to :document_kind
  belongs_to :order
  has_many :client_document_fields

  validates :image, presence: true
  validates :document_kind_id, uniqueness: { scope: :order_id }

  workflow do
    state :pending do
      event :accept, transitions_to: :accepted
      event :reject, transitions_to: :rejected
    end

    state :accepted do
      event :reject, transitions_to: :rejected
    end

    state :rejected do
      event :accept, transitions_to: :accepted
    end
  end

  after_create do
    order.load! if order.none? && order.complete?
  end
end
