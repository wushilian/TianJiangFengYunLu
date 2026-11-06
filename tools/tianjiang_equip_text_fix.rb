# Fix overlapping text in the item-use status window (Window_zhuangbei).
#
# 1. The window is nearly transparent, so the hidden item list / target window
#    shows through and its quantity numbers overlap the equipment names.
#    Redraw the wupinshiyong panel background into the contents bitmap first,
#    which makes the inner area opaque while keeping the original panel art.
# 2. draw_actor_parameter2 placed the value at x + 4 + value_width, which lands
#    inside the label for 3-character labels (e.g. 防御:). Use a fixed label
#    width instead.

class Window_Base
  def draw_actor_parameter2(actor, x, y, type)
    case type
    when 0
      parameter_name = "攻击:"
      parameter_value = actor.atk
    when 1
      parameter_name = "防御:"
      parameter_value = actor.pdef
    when 2
      parameter_name = " "
      parameter_value = actor.mdef
    when 3
      parameter_name = " "
      parameter_value = actor.str
    when 4
      parameter_name = "幸运:"
      parameter_value = actor.dex
    when 5
      parameter_name = "身法:"
      parameter_value = actor.agi
    when 6
      parameter_name = "灵力:"
      parameter_value = actor.int
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 80, 32, parameter_name)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 84, y, 64, 32, parameter_value.to_s, 2)
  end
end

class Window_zhuangbei < Window_Base
  def refresh
    self.contents.clear

    # Opaque panel background (same art as Graphics/Pictures/wupinshiyong.png).
    begin
      background = RPG::Cache.picture("wupinshiyong")
      self.contents.blt(0, 0, background,
                        Rect.new(16, 16, self.width - 32, self.height - 32))
    rescue
    end

    draw_actor_graphic(@actor, 96, 240)

    self.contents.font.size = 26
    draw_actor_parameter2(@actor, 400, 32 * 5, 6)
    draw_actor_parameter2(@actor, 400, 32 * 6, 4)
    draw_actor_parameter2(@actor, 400, 32 * 7, 5)
    draw_actor_parameter2(@actor, 400, 32 * 8, 0)
    draw_actor_parameter2(@actor, 400, 32 * 9, 1)

    self.contents.font.size = 26
    self.contents.font.color = system_color
    self.contents.draw_text(150, 32 * 3, 92, 32, "帽子:")
    self.contents.draw_text(150, 32 * 4, 92, 32, "衣着:")
    self.contents.draw_text(150, 32 * 5, 92, 32, "武器:")
    self.contents.draw_text(150, 32 * 6, 92, 32, "靴子:")
    self.contents.draw_text(150, 32 * 7, 92, 32, "饰品:")
    self.contents.draw_text(150, 32 * 8, 92, 32, "饰物:")
    self.contents.draw_text(150, 32 * 9, 92, 32, "法器:")
    self.contents.draw_text(400, 32 * 3, 92, 32, "状态:")
    self.contents.draw_text(400, 32 * 4, 92, 32, "免疫:")
    draw_actor_state(@actor, 400 + 64, 32 * 3)

    draw_item_name3($data_weapons[@actor.weapon_id], 150 + 48, 32 * 5)
    draw_item_name3($data_armors[@actor.armor1_id], 150 + 48, 32 * 6)
    draw_item_name3($data_armors[@actor.armor2_id], 150 + 48, 32 * 3)
    draw_item_name3($data_armors[@actor.armor3_id], 150 + 48, 32 * 4)
    draw_item_name3($data_armors[@actor.armor4_id], 150 + 48, 32 * 7)
    draw_item_name3($data_armors[@actor.armor5_id], 150 + 48, 32 * 8)
    draw_item_name3($data_armors[@actor.armor6_id], 150 + 48, 32 * 9)
  end
end
