# Defensive fixes for several crash / nil paths in the custom battle and
# equipment scripts.

class Game_Actor
  def tj_equip_position(item)
    return nil if item == nil
    if item.is_a?(RPG::Weapon)
      return 0
    end
    if item.is_a?(RPG::Armor)
      kind = item.kind
      return nil if kind == nil
      case kind
      when 0 then return 1
      when 1 then return 2
      when 2 then return 3
      when 3 then return 4
      when 4 then return 5
      when 5 then return 6
      end
    end
    return nil
  end

  alias tj_crash_safe_equip equip
  def equip(equip_type, id)
    return if equip_type == nil
    return unless equip_type.is_a?(Integer)
    return unless equip_type >= 0 and equip_type <= 6
    if equip_type == 0
      return if id != 0 and $data_weapons[id] == nil
    else
      return if id != 0 and $data_armors[id] == nil
    end
    tj_crash_safe_equip(equip_type, id)
  end

  alias tj_crash_safe_equippable? equippable?
  def equippable?(item)
    return false if item == nil
    tj_crash_safe_equippable?(item)
  end
end

# ---------------------------------------------------------------------------
# Item-use window: guard nil item and invalid equipment kinds.
# ---------------------------------------------------------------------------
class Scene_Item2
  alias tj_crash_update_item update_item

  def update_item
    if Input.trigger?(Input::C) and @item_window != nil and @item_window.item == nil
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    tj_crash_update_item
  end

  alias tj_crash_update_target update_target

  def update_target
    if @item == nil
      @item_window.active = true if @item_window != nil
      @item_window.visible = true if @item_window != nil
      @status_actor_window.active = false if @status_actor_window != nil
      @wupinshiyong_window.visible = false if @wupinshiyong_window != nil
      return
    end
    if Input.trigger?(Input::C)
      if @item.is_a?(RPG::Armor)
        kind = @item.kind
        if kind == nil or kind < 0 or kind > 5
          $game_system.se_play($data_system.buzzer_se)
          Graphics.tips("无法装备该物品")
          return
        end
      end
    end
    tj_crash_update_target
  end
end

# ---------------------------------------------------------------------------
# Battle: safe He-ji (combined attack) and skill-window guards.
# ---------------------------------------------------------------------------
class Scene_Battle
  def make_heji
    if @active_battler == nil or @active_battler.current_action == nil
      return
    end
    if @active_battler.current_action.basic != 0
      return
    end
    common_event = $data_common_events[7]
    if common_event == nil
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    @active_battler.startactive = "阵亡" if @active_battler.respond_to?(:startactive=)
    $game_system.battle_interpreter.setup(common_event.list, 0)
    start_phase4
    @actor_command_window.active = true if @actor_command_window != nil
  end

  alias tj_crash_skill_select update_phase3_skill_select

  def update_phase3_skill_select
    if @skill_window == nil
      @actor_command_window.active = true if @actor_command_window != nil
      return
    end
    tj_crash_skill_select
  end
end
