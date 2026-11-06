class Scene_Battle
  # 婆婆的考验是真正可以打的战斗：虽然允许失败（失败也继续事件），
  # 但不能套用“可败剧情战开战即全灭”的自动判负。
  TJ_STORY_KO_ALLOW_FIGHT_TROOPS = [301]

  alias tj_story_ko_start_phase1 start_phase1

  def start_phase1
    troop_id = $game_temp.battle_troop_id
    if $game_temp.battle_can_lose and !TJ_STORY_KO_ALLOW_FIGHT_TROOPS.include?(troop_id)
      $game_party.actors.each do |actor|
        actor.hp = 0
      end
    end
    tj_story_ko_start_phase1
  end

  alias tj_story_ko_battle_end battle_end

  def battle_end(result)
    troop_id = $game_temp.battle_troop_id
    tj_story_ko_battle_end(result)
    if result == 2 and $game_temp.battle_can_lose and
       !TJ_STORY_KO_ALLOW_FIGHT_TROOPS.include?(troop_id)
      $game_party.actors.each do |actor|
        actor.hp = actor.maxhp
      end
    end
  end
end
