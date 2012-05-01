class User

  attr_accessor :soc_params

  include Mongoid::Document

  field :social_type_id, :type => Integer, :null => false
  field :uid, :type => Integer, :null => false
  field :friend_uids, :type => String
  field :first_name, :type => String
  field :last_name, :type => String
  field :middle_name, :type => String
  field :nickname, :type => String
  field :birthdate, :type => Date
  field :city, :type => String
  field :country, :type => String
  field :avatar_url, :type => String
  field :url_profile, :type => String
  field :email, :type => String
  field :male, :type => Boolean
  field :game_balance, :type => Float, :default => 0.0, :null => false # coins
  field :real_balance, :type => Float, :default => 1.0, :null => false # gold
  field :bonus_balance, :type => Float, :default => 1.0, :null => false # gold
  field :remember_token, :type => String
  field :installed, :type => Boolean, :default => false, :null => false
  field :last_lanched_at, :type => DateTime
  field :intro_display_at, :type => DateTime
  field :tutorial_display_at, :type => DateTime
  field :last_update_soc_attributes_at, :type => DateTime
  field :unviewed_quantity, :default => 0, :type => Integer, :null => false

  index :remember_token
  index [[:social_type_id, Mongo::ASCENDING], [:uid, Mongo::ASCENDING]], unique: true
  
  before_create :generate_remember_token!, unique: true

  def generate_remember_token!
    self.remember_token ||= Digest::SHA1.hexdigest("#{id}_#{Time.now.utc}_#{rand(100)}")
  end

  def unviewed_quantity_inc!
    self.unviewed_quantity += 1
    self.save
  end

  def unviewed_quantity_dec!
    if self.unviewed_quantity > 0
      self.unviewed_quantity -= 1
      self.save
    end
  end

  def have_gold(amount)
    self.real_balance >= amount.to_f
  end

  def have_coins(amount)
    self.game_balance >= amount.to_f
  end

  def charge_off_gold!(amount)
    unless self.have_gold(1)
      raise "Not have money by user #{@current_user.id} balance is #{@current_user.real_balance}, needed #{amount}"
    end

    self.update_attribute(:real_balance, self.real_balance - amount.to_f)
  end

  def to_front
    attributes.slice(
      'social_type_id',
      'uid',
      'friend_uids',
      'first_name',
      'last_name',
      'middle_name',
      'nickname',
      'birthdate',
      'avatar_url',
      'male',
      'game_balance',
      'real_balance',
      'bonus_balance',
      'intro_display_at',
      'tutorial_display_at',
      'unviewed_quantity'
    )
  end

  def update_social_attributes!
    update_attributes(self.class.social_info(self.uid))
  end

  def try_update!
    self.update_attribute(:last_lanched_at, Time.now)
    
    #unless last_update_soc_attributes_at
    #  update_attribute(:last_update_soc_attributes_at, 15.day.ago) 
    #end

    unless self.installed?
      self.update_attribute(:installed, true)
    end

    if self.last_update_soc_attributes_at < 10.day.ago
      self.update_social_attributes!
    end
  end

  ####### Synergy

  def social_type
    Social.type_by_id(self.social_type_id)
  end

  def api
    Social::Network(social_type)
  end

  def refresh_real_balance!(&block)
    if ENV['APP_ENV'] != 'production'
      return block.call if block_given?
    end

    api.user.balance(self.uid) do |balance|
      if not balance.nil? # with OK
        current_balance = balance
        user_balance = self.real_balance.to_f

        if user_balance != current_balance
          self.update_attribute(:real_balance, current_balance)
        end
      end

      block.call if block_given?
    end
  end

  def charge_off_real_balance!(amount, &block)

    start_balance = self.real_balance
    new_balance = start_balance - amount

    raise "Real balance can\'t be SubZero (#{start_balance} - #{amount}) < 0" if new_balance < 0

    if ENV['APP_ENV'] != 'production'
      self.update_attribute(:real_balance, new_balance)
      return block.call if block_given?
    end

    api.user.charge_off_balance(self.uid, amount) do # вслучае чаго перенести в отдельный метод
      self.refresh_real_balance! do

        if start_balance < self.real_balance
          raise "Balance start #{start_balance} < current #{self.real_balance} after charge off" 
        end

        if self.real_balance != new_balance
          raise "Balance new #{new_balance} != current #{self.real_balance} after charge off"
        end

        block.call if block_given?

      end
    end
  end

  # Списываем реальные деньги и выполняем блок
  def charge_off_real_and_call!(amount, &block)
    if amount <= self.real_balance && amount <= self.bonus_balance
      new_real_balance = self.real_balance - amount
      new_bonus_balance = self.bonus_balance - amount
      self.update_attribute(:real_balance, new_real_balance)
      self.update_attribute(:bonus_balance, new_bonus_balance)
      block.call
    else
      self.refresh_real_balance! do
        self.charge_off_real_balance!(amount) { block.call }
      end
    end
  end

  # Списываем игровые деньги и выполняем блок
  def charge_off_game_and_call!(amount, &block)
    if amount <= self.game_balance
      new_game_balance = self.game_balance - amount
      self.update_attribute(:game_balance, new_game_balance)
      block.call
    end
  end

  ##### / Synergy

  class << self

    def attributes_from_social(info)
      return {} if info.empty?

      if Social::Env.type.to_sym == :ok
        return {
          :nickname     => info['nickname'],
          :first_name   => info['first_name'],
          :last_name    => info['last_name'],
          :city         => info['location'].try(:fetch, 'city'),
          :country      => info['location'].try(:fetch, 'country'),
          #:birthdate    => info["birthdate"] ? Time.parse(info["birthdate"]) : nil, тк 17.10 непонятно как парсит
          :url_profile  => info['url_profile'],
          :avatar_url   => info['pic_1'],
          :male         => info['gender'] != 'female'
        }
      elsif Social::Env.type.to_sym == :vk
        return {
          :nickname     => info['nickname'],
          :first_name   => info['first_name'],
          :last_name    => info['last_name'],
          :birthdate    => info["birthdate"] ? Time.parse(info["birthdate"]) : nil,
          :avatar_url   => info['photo'],
          :male         => info['sex'].try(:to_i) == 2
        }
      end

      return {}
    end

    def social_info(uid)
      if ENV['APP_ENV'] == 'production'
        results = Social::Network(Social::Env.type).user.get_info(uid)
        info = results.first
      else
        info = {}
      end

      return attributes_from_social(info)
    end

    def signup(uid)
      attributes = social_info(uid)
      attributes.merge!({ 
        :uid => uid, 
        :social_type_id => Social::Env.id,
        :last_lanched_at => Time.now,
        :last_update_soc_attributes_at => Time.now
      })

      User.create(attributes)
    end

    def find_or_create_by_uid(uid, social_type_id = nil)
      social_type_id ||= Social::Env.id
      user = self.where(:uid => uid, :social_type_id => social_type_id).last
      user ||= User.signup(uid)
    end

    def find_by_remember_token(token)
      user = self.where(:remember_token => token).last

      unless user
        raise 'Can\'t find user by remember_token: ' + token.to_s 
      end

      if user.social_type_id != Social::Env.id
        raise "Finded user #{user.id} by remember_token: #{token} not supported current social_type_id"
      end
      
      return user
    end

  end

end