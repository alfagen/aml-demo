# frozen_string_literal: true

class Client < ApplicationRecord
  scope :ordered, -> { order 'id desc' }

  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :inn, presence: true, uniqueness: true
end
