# frozen_string_literal: true

require "validator/email_validator"

class User < ApplicationRecord

  include UserAuth::Tokenizable
  before_validation :downcase_email
  has_secure_password

  # validates
  validates :name, presence: true,
                   length: { maximum: 30, allow_blank: true }
  validates :email, presence: true,
                    email: { allow_blank: true }
  VALID_PASSWORD_REGEX = /\A[\w\-]+\z/
  validates :password, presence: true,
                       length: { minimum: 8 },
                       format: {
                         with: VALID_PASSWORD_REGEX,
                         message: :invalid_password
                       },
                       allow_nil: true
  validates :activated, inclusion: { in: [ true, false ] }

  ## methods
  # class method  ############################
  class << self
    # emailからアクティブなユーザーを返す
    def find_activated(email)
      find_by(email: email, activated: true)
    end
  end
  # class method end  ########################

  # 自分以外の同じemailのアクティブなユーザーが居る場合にtrueを返す
  def email_activated?
    users = User.where.not(id: id)
    users.find_activated(email).present?
  end

  # 共通のJSONレスポンス
  def my_json
    as_json(only: %i[id name email created_at])
  end

  private

  # email小文字化
  def downcase_email
    email&.downcase!
  end
end