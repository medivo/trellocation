module Trellocation; class Report

  def self.run
    CONFIG.trello_board_ids.each do |k,v|
      list = List.new(v)
      list.generate_output
    end
    Card.run
  end

end; end
