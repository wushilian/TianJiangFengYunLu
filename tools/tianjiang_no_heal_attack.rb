# Normal (basic) attacks must never heal the target.
# Some element / variance combinations can produce a negative damage value,
# which the original attack_effect applies as "hp -= negative" (a heal).
# Keep the original result but undo the HP gain and show 0 damage instead.
class Game_Battler
  alias tj_no_heal_attack attack_effect

  def attack_effect(attacker)
    before_hp = self.hp
    result = tj_no_heal_attack(attacker)
    if self.damage.is_a?(Numeric) and self.damage < 0
      self.hp = before_hp
      self.damage = 0
    end
    result
  end
end
