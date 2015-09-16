module Trellocation; class Card < ActiveRecord::Base
  establish_connection(
    :adapter => "postgresql",
    :database => "trellocation"
  )

  def self.run
    Card.collect_data
    Card.output
  end

  def self.collect_data
    CONFIG.trello_board_ids.each do |k,v|
      list = Trello::List.find(v)

      board_name = list.board.name.downcase
      puts board_name

      list.cards.each do |card|
        puts card.short_id
        bucket = "undefined"
        bucket = CONFIG.mapping[card.tag] if CONFIG.mapping.keys.include?(card.tag)

        c = Card.new
        c.card_number = card.short_id
        c.title = card.name
        c.tag = card.tag
        c.points = card.points
        c.url = card.short_url
        c.board_name = board_name
        c.team = board_name[0...-4]
        c.bucket = bucket
        c.save
      end
    end
  end

  def self.output
    f = File.open("#{Date::MONTHNAMES[Date.today.month-1]}_#{Date.today.year}_buckets_report.markdown", "w+")

    f.write("#{Date::MONTHNAMES[Date.today.month-1]} #{Date.today.year} buckets report\n")
    f.write("===\n")

    f.write("\nbuckets breakdown\n")
    f.write("---\n")

    buckets_hash = Trellocation::Card.group(:bucket).sum(:points)
    total_points = Trellocation::Card.sum(:points).to_f

    f.write("|bucket|points|percentage|\n")
    f.write("|---|---|---|\n")

    buckets_hash.each do |k,v|
      percentage = v / total_points * 1000
      percentage = percentage.truncate / 10.0
      f.write("|#{k}|#{v}|#{percentage}|\n")
    end
    f.write("|**total**|**#{total_points}**|100.0%|\n")

    f.write("\nteam breakdown\n")
    f.write("---\n")

    teams_hash = Trellocation::Card.group(:team).sum(:points)
    f.write("|team|points|percentage|\n")
    f.write("|---|---|---|\n")

    teams_hash.each do |k,v|
      percentage = v / total_points * 1000
      percentage = percentage.truncate / 10.0
      f.write("|#{k}|#{v}|#{percentage}|\n")
    end
    f.write("|**total**|**#{total_points}**|100.0%|\n")

    f.close
  end

end;end
