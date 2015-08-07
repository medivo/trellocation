class Trello::Card

  def points
    value = name.strip[/\A\((\d+|\d+\.\d+|\.\d+)\)/, 1]
    return 0 if value.blank?
    value.to_f
  end

  def tag_string
    name.strip[/\{(.+)\}\z/, 1]
  end

  def tag
    return "empty" if tag_string.blank?
    tag_string.downcase.strip
  end

  def engineer_ids
    members.map(&:id) & CONFIG.engineers.keys
  end

  def number_of_engineers
    engineer_ids.count
  end

  def empty_tag?
    tag == "empty"
  end

  def no_points?
    points < 0.5
  end

  def no_member?
    member_ids.count == 0
  end

  def label
    card_labels.first["name"]
  end

  def has_label?
    !card_labels.empty?
  end

  def developers_names
    card_members.select{ |member| CONFIG.developers.include?(memeber.full_name) }
  end

end
