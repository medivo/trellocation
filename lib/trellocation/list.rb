module Trellocation; class List

  attr_reader :list

  def initialize(list_id)
    @list = Trello::List.find(list_id)
  end

  def cards
    list.cards
  end

  def cards_with_labels
    cards.select{ |card| card.has_label? }
  end

  def card_labels
    cards_with_labels.map{ |each| each.card_labels.first["name"] }.uniq.sort
  end

  def generate_output
    f = File.open("#{Date::MONTHNAMES[Date.today.month-1]}_#{Date.today.year}_#{list.board.name}_report.markdown", "w+")
    f.write("#{Date::MONTHNAMES[Date.today.month-1]} #{Date.today.year} #{list.board.name} report\n")
    f.write("===\n")

    f.write("\ntags used\n")
    f.write("---\n")
    f.write("#{tags_used.join(',')}\n")

    f.write("\npoints breakdown\n")
    f.write("---\n")
    f.write("|tag|points|percentage|\n")
    f.write("|---|---|---|\n")

    points_breakdown.sort.each do |array|
      percentage = array.last/total_points * 1000
      percentage = percentage.truncate/10.0
      f.write("|#{array.first}|#{array.last}|#{percentage}|\n")
    end
    f.write("|**TOTAL**|**#{total_points}**|100.0%|\n")

    f.write("individual points breakdown\n")
    f.write("---\n")
    f.write("||#{tags_used.join('|')}|**TOTAL**|\n")
    f.write("#{'|---'*(tags_used.count+2)}|\n")

    team_member_stats = members_stats.sort.map{ |array| array.last }

    team_member_stats.each do |person|
      full_name = person.full_name
      points = person.points
      work = person.work

      f.write("|#{full_name}")
      tags_used.each do |tag|
        if work.has_key?(tag)
          f.write("|#{work[tag]}")
        else
          f.write("|")
        end
      end
      f.write("|#{points}|\n")
    end

    f.write("\nteam contribution\n")
    f.write("---\n")
    f.write("|name|percentage|\n")
    f.write("|---|---|\n")

    weighted_total_points = team_member_stats.sum(&:points)
    team_member_stats.each do |person|
      percentage = person.points/weighted_total_points * 1000
      percentage = percentage.truncate/10.0
      f.write("|#{person.full_name}|#{percentage}|\n")
    end
    f.write("|**TOTAL**|100.0%|")


    f.write("\ncards with labels\n")
    f.write("---\n")
    f.write("|index|points|card title|card #|url|label|\n")
    f.write("|---|---|---|---|---|---|\n")

    cards_with_labels.each_with_index do |card, index|
      f.write("|#{index+1}|#{card.points}|#{card.name}|#{card.short_id}|#{card.short_url}|#{card.label}|\n")
    end

    f.write("\nlabels breakdown\n")
    f.write("---\n")
    f.write("|label|points|percentage of work|\n")
    f.write("|---|---|---|\n")

    card_labels.each do |label|
      total = 0
      cards_with_labels.each do |card|
        if card.card_labels.first["name"] == label
          total += card.points
        end
      end
      percentage = total.to_f/total_points * 1000
      percentage = percentage.truncate/10.0
      f.write("|#{label}|#{total}|#{percentage}|\n")
    end


    f.write("\ncards\n")
    f.write("---\n")
    f.write("|index|card title|card #|url|missing tag|missing points|missing faces|\n")
    f.write("|---|---|---|---|---|---|---|\n")

    cards.each_with_index do |card, index|
      f.write("|#{index+1}|#{card.name}|#{card.short_id}|#{card.short_url}|#{'X' if card.empty_tag?}|#{'X' if card.no_points?}|#{'X' if card.no_member?}|\n")
    end

    f.close
  end

  def tags_used
    cards.map{ |card| card.tag }.uniq.sort
  end

  def total_points
    @total_points ||= cards.sum(&:points)
  end

  def points_breakdown
    hash = {}
    cards.each do |card|
      if hash.has_key?(card.tag)
        hash[card.tag] += card.points
      else
        hash[card.tag] = card.points
      end
    end
    hash
  end

  def members_stats
    team_members = {}

    cards.each do |card|
      puts "#{card.short_id} #{card.name}"

      card.members.each do |member|
        if team_members.has_key?(member.full_name)
          team_member = team_members[member.full_name]

          team_member.points += card.points
          if team_member.work.has_key?(card.tag)
            team_member.work[card.tag] += card.points
          else
            team_member.work[card.tag] = card.points
          end
        else
          team_member = Member.new(member.full_name)
          team_member.points = card.points
          team_member.work[card.tag] = card.points
          team_members[member.full_name] = team_member
        end
      end
    end

    team_members
  end

end; end
