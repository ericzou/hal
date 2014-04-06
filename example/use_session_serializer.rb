class UserSessionSerializer

  def initialize(session, current_user, users)
  end

  def links
    relation :current_user, href: current_user_url

    relation :users do |user|
      link href: user_url
    end
  end

  def embedded
    resource :current_user, seralizer: CurrentUserSerializer.new(current_user)
    resources :users
  end
end

class CurrentUserSerializer
  attributes :name

  def initialize(current_user)
  end
end

class UserSerializer

  attributes :name, :full_name, :admin

  def initialize(user)
  end

  def links
  end
end