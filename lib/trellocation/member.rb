module Trellocation; class Member

  attr_reader :full_name, :work
  attr_accessor :points

  def initialize(full_name)
    @full_name = full_name
    @points = 0
    @work = {}
  end

end; end;
