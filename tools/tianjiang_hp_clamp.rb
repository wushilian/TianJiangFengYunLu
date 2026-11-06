# Clamp HP to the current MaxHP.
#
# Some custom battle / suit / equipment paths change MaxHP or apply healing
# without clamping the current HP, which leaves states like "163 / 130" on the
# map after a battle. Clamp both assignment and read paths, and re-clamp the
# whole party when a battle ends.

class Game_Actor
  alias tj_hp_clamp_set hp=
  def hp=(value)
    value = value.to_i
    value = 0 if value < 0
    value = maxhp if value > maxhp
    tj_hp_clamp_set(value)
  end

  alias tj_hp_clamp_get hp
  def hp
    value = tj_hp_clamp_get
    if value > maxhp
      @hp = maxhp
      value = maxhp
    end
    value
  end
end

class Scene_Battle
  alias tj_hp_clamp_battle_end battle_end

  def battle_end(result)
    tj_hp_clamp_battle_end(result)
    if $game_party != nil
      $game_party.actors.each do |actor|
        actor.hp = [[actor.hp, actor.maxhp].min, 0].max
      end
    end
  end
end
