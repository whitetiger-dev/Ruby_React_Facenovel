class User < ApplicationRecord
  validates :email, :session_token, :user_url, presence: true, uniqueness: true
  validates :password_digest, presence: true
  after_initialize :ensure_session_token, :ensure_user_url

  attr_reader :password

  def self.generate_session_token
    SecureRandom.urlsafe_base64(16)
  end

  def self.find_by_credentials(email, password)
    user = User.find_by(email: email)
    user && user.is_password?(password) ? user : nil
  end

  def reset_session_token!
    self.session_token = User.generate_session_token;
    self.save
    self.session_token
  end

  def ensure_session_token
    self.session_token ||= User.generate_session_token
  end

  def ensure_user_url
    self.user_url ||= User.generate_session_token
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(password)
    BCrypt::Password.new(password_digest).is_password?(password)
  end
end
