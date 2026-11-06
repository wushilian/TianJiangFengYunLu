# Speed up player movement (original base speed is 3.8 in Game_Character).
# 1.9 ** speed is the per-frame movement distance in 1/128 tile units, so
# 4.6 is roughly 1.6x the original speed.
module TianJiangMoveSpeed
  SPEED = 4.6
end

class Game_Player
  alias tj_move_speed_initialize initialize

  def initialize
    tj_move_speed_initialize
    @move_speed = TianJiangMoveSpeed::SPEED
  end
end
