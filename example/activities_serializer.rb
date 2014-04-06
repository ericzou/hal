class ActivitiesSerializer
  def initialize(activities)
  end

  def links
    relation :activities do |activity|
      link href: activity
    end
  end

  def embedded
    resources :activities
  end
end


class ActivitySerializer
  attributes :motive, :updated_at

  def initialize(activity)
    @activity = activity
    @related_content = @activity.related_content
  end

  def links
    relation :related_content, href: related_content_url
  end
end