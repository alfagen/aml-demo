# frozen_string_literal: true

class ClientDocument < ApplicationRecord
  extend Enumerize
  include Workflow
  mount_uploader :file, FileUploader

  enumerize :workflow_state, in: %w[pending accepted rejected], scope: true

  scope :ordered, -> { order 'id desc' }

  belongs_to :document_kind
  belongs_to :order

  validates :file, presence: true
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
    if DocumentKind.where.not(id: order.client_documents.select(:document_kind_id)).size == 0
      order.load! if order.pending?
    end
  end
end
