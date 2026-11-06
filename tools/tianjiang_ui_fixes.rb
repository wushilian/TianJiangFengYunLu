module TianJiangUIFixes
  SCOPE_NAMES = {
    0 => "特殊", 1 => "单体敌人", 2 => "全体敌人",
    3 => "单体友方", 4 => "全体友方", 5 => "倒下的友方单体",
    6 => "倒下的友方全体", 7 => "自身"
  }
  ELEMENT_NAMES = { 1 => "火", 2 => "冰", 3 => "雷", 4 => "水", 5 => "土", 6 => "风", 7 => "光", 8 => "暗" }

  def self.skill_description(skill, actor)
    return skill.description if skill.nil?
    defn = (defined?(WuxiaEasterEggs) && WuxiaEasterEggs::SKILL_BY_ID[skill.id]) || nil
    return skill.description if defn.nil? || actor.nil?

    parts = []
    parts << SCOPE_NAMES[skill.scope] if SCOPE_NAMES[skill.scope]
    unless skill.element_set.nil? || skill.element_set.empty?
      elems = skill.element_set.map { |e| ELEMENT_NAMES[e] }.compact
      parts << (elems.join("/") + "属性") unless elems.empty?
    end

    if skill.power != 0
      power = skill.power + actor.atk * skill.atk_f / 100
      rate = 20
      rate += actor.str * skill.str_f / 100
      rate += actor.dex * skill.dex_f / 100
      rate += actor.agi * skill.agi_f / 100
      rate += actor.int * skill.int_f / 100
      value = (power * rate / 20).to_i
      if value < 0
        parts << "按当前属性，基础恢复约 #{value.abs} 点生命"
      else
        text = "按当前属性，基础伤害约 #{value} 点"
        text += "（浮动#{defn[:variance].to_i}%）" if defn[:variance].to_i > 0
        parts << text
        if defn[:lifesteal]
          parts << "命中后回复约 #{(value * defn[:lifesteal]).to_i} 点生命"
        end
      end
    end

    plus = defn[:plus] || []
    minus = defn[:minus] || []
    unless plus.empty?
      names = plus.map { |id| $data_states[id] ? $data_states[id].name : nil }.compact
      parts << "附加：#{names.join("、")}" unless names.empty?
    end
    unless minus.empty?
      if minus.size > 4
        parts << "解除大部分负面状态"
      else
        names = minus.map { |id| $data_states[id] ? $data_states[id].name : nil }.compact
        parts << "解除：#{names.join("、")}" unless names.empty?
      end
    end
    parts << "吸取目标#{defn[:sp_drain]}点真气" if defn[:sp_drain]
    parts << "消耗#{skill.sp_cost}真气"
    parts.join("；") + "。"
  end
end

class Window_Helpjineng
  def set_text(text, align = 0)
    text = text.to_s
    return self.visible = false if text.empty?
    key = [text, align]
    return if @tj_help_render_key == key && self.contents
    @tj_help_render_key = key
    self.contents.clear
    self.contents.font.name = ["Noto Sans CJK SC"]
    self.contents.font.size = 20
    self.contents.font.color = normal_color
    lines = wrap_text(text, self.contents.width - 8)
    lines.first(5).each_with_index do |line, i|
      self.contents.draw_text(4, 4 + i * 24, self.contents.width - 8, 24, line, align)
    end
    @last_text = text
    @align = align
    self.visible = true
  end

  def wrap_text(text, width)
    lines = []
    line = ""
    text.each_char do |ch|
      if ch == "\n"
        lines << line
        line = ""
      elsif self.contents.text_size(line + ch).width <= width
        line += ch
      else
        lines << line unless line.empty?
        line = ch
      end
    end
    lines << line unless line.empty?
    lines
  end
end


class Window_Help_Self
  TJ_SCOPE_NAMES = {
    0 => "特殊", 1 => "敌单体", 2 => "敌全体",
    3 => "己方单体", 4 => "己方全体", 5 => "己方昏死单体",
    6 => "己方昏死全体", 7 => "使用者"
  }
  TJ_PARAM_NAMES = {
    1 => "生命上限", 2 => "法力上限", 3 => "力量",
    4 => "灵巧", 5 => "速度", 6 => "灵力"
  }

  def set_item_text(item)
    @item = item
    footer = []
    footer << "价格 #{item.price}"
    footer << "范围 #{TJ_SCOPE_NAMES[item.scope] || "特殊"}"
    if item.recover_hp_rate != 0
      footer << "HP回复#{item.recover_hp_rate}%"
    end
    if item.recover_hp != 0
      footer << "HP+#{item.recover_hp}"
    end
    if item.recover_sp_rate != 0
      footer << "SP回复#{item.recover_sp_rate}%"
    end
    if item.recover_sp != 0
      footer << "SP+#{item.recover_sp}"
    end
    if item.parameter_type != 0
      footer << "#{TJ_PARAM_NAMES[item.parameter_type] || "属性"}+#{item.parameter_points}"
    end
    unless item.element_set.empty?
      elems = item.element_set.map { |e| TianJiangUIFixes::ELEMENT_NAMES[e] }.compact
      footer << "属性#{elems.join("/")}" unless elems.empty?
    end
    unless item.plus_state_set.empty?
      footer << "附加#{tj_state_names(item.plus_state_set)}"
    end
    unless item.minus_state_set.empty?
      footer << "解除#{tj_state_names(item.minus_state_set)}"
    end
    footer << "特殊效果" if item.common_event_id.to_i > 0
    draw_tj_help(item.description, footer.join("｜"))
  end

  def set_weapon_text(weapon)
    @weapon = weapon
    footer = ["价格 #{weapon.price}", "攻击+#{weapon.atk}"]
    footer << "物防+#{weapon.pdef}" if weapon.pdef != 0
    footer << "仙防+#{weapon.mdef}" if weapon.mdef != 0
    footer << "力量+#{weapon.str_plus}" if weapon.str_plus != 0
    footer << "灵巧+#{weapon.dex_plus}" if weapon.dex_plus != 0
    footer << "速度+#{weapon.agi_plus}" if weapon.agi_plus != 0
    footer << "灵力+#{weapon.int_plus}" if weapon.int_plus != 0
    unless weapon.element_set.empty?
      elems = weapon.element_set.map { |e| TianJiangUIFixes::ELEMENT_NAMES[e] }.compact
      footer << "属性#{elems.join("/")}" unless elems.empty?
    end
    unless weapon.plus_state_set.empty?
      footer << "附加#{tj_state_names(weapon.plus_state_set)}"
    end
    unless weapon.minus_state_set.empty?
      footer << "解除#{tj_state_names(weapon.minus_state_set)}"
    end
    draw_tj_help(weapon.description, footer.join("｜"))
  end

  def set_armor_text(armor)
    @armor = armor
    footer = ["价格 #{armor.price}"]
    footer << "物防+#{armor.pdef}" if armor.pdef != 0
    footer << "仙防+#{armor.mdef}" if armor.mdef != 0
    footer << "力量+#{armor.str_plus}" if armor.str_plus != 0
    footer << "灵巧+#{armor.dex_plus}" if armor.dex_plus != 0
    footer << "速度+#{armor.agi_plus}" if armor.agi_plus != 0
    footer << "灵力+#{armor.int_plus}" if armor.int_plus != 0
    unless armor.guard_element_set.empty?
      elems = armor.guard_element_set.map { |e| TianJiangUIFixes::ELEMENT_NAMES[e] }.compact
      footer << "属性防御#{elems.join("/")}" unless elems.empty?
    end
    unless armor.guard_state_set.empty?
      footer << "免疫#{tj_state_names(armor.guard_state_set)}"
    end
    draw_tj_help(armor.description, footer.join("｜"))
  end

  def set_skill_text(skill)
    @skill = skill
    footer = ["消耗#{skill.sp_cost}真气"]
    footer << "范围#{TJ_SCOPE_NAMES[skill.scope] || "特殊"}"
    footer << "威力#{skill.power}" if skill.power != 0
    draw_tj_help(skill.description, footer.join("｜"))
  end

  def tj_state_names(ids, limit = 4)
    names = ids.map { |id| $data_states[id] ? $data_states[id].name : nil }.compact
    text = names.first(limit).join("/")
    text += "等" if names.size > limit
    text
  end

  def draw_tj_help(description, footer)
    description = description.to_s
    key = [description, footer]
    return if @tj_help_render_key == key && self.contents
    @tj_help_render_key = key
    self.height = 124
    self.contents.dispose if self.contents
    self.contents = Bitmap.new(self.width - 32, 92)
    self.contents.font.name = ["Noto Sans CJK SC"]
    self.contents.font.color = normal_color
    self.contents.font.size = 20
    lines = tj_help_wrap(description, 500).first(3)
    lines.each_with_index do |line, i|
      self.contents.draw_text(100, 4 + i * 22, 500, 22, line, 0)
    end
    foot_lines = tj_help_wrap(footer, 500)
    foot_lines = foot_lines.first(lines.size >= 3 ? 1 : 2)
    self.contents.font.size = 14
    fy = 4 + lines.size * 22 + 4
    foot_lines.each_with_index do |line, i|
      self.contents.draw_text(100, fy + i * 16, 500, 16, line, 0)
    end
    self.visible = true
  end

  def tj_help_wrap(text, width)
    lines = []
    line = ""
    text.each_char do |ch|
      if ch == "\n"
        lines << line
        line = ""
      elsif self.contents.text_size(line + ch).width <= width
        line += ch
      else
        lines << line unless line.empty?
        line = ch
      end
    end
    lines << line unless line.empty?
    lines
  end
end

class Window_Helpbuy
  def set_text(text, align = 0)
    text = text.to_s
    self.contents.clear
    return self.visible = false if text.empty?
    self.contents.font.name = ["Noto Sans CJK SC"]
    self.contents.font.size = 16
    self.contents.font.color = normal_color
    lines = wrap_text(text, self.contents.width - 8)
    lines.first(6).each_with_index do |line, i|
      self.contents.draw_text(4, i * 18, self.contents.width - 8, 18, line, align)
    end
    @last_text = text
    @align = align
    self.visible = true
  end

  def wrap_text(text, width)
    lines = []
    line = ""
    text.each_char do |ch|
      if ch == "\n"
        lines << line
        line = ""
      elsif self.contents.text_size(line + ch).width <= width
        line += ch
      else
        lines << line unless line.empty?
        line = ch
      end
    end
    lines << line unless line.empty?
    lines
  end
end


class Window_caidan
  def update
    Window_Base.instance_method(:update).bind(self).call
    if self.active and @item_max > 0 and @index >= 0
      if Input.trigger?(Input::DOWN)
        if @index < @item_max - 1
          $game_system.se_play($data_system.cursor_se)
          @index += 1
        end
      elsif Input.trigger?(Input::UP)
        if @index > 0
          $game_system.se_play($data_system.cursor_se)
          @index -= 1
        end
      end
    end
    if self.active and @help_window != nil
      update_help
    end
    update_cursor_rect
  end
end

class Window_ShopBuy
  def initialize(shop_goods)
    super(192, 0, 448, 320)
    @shop_goods = shop_goods
    @column_max = 1
    refresh
    self.index = 0
  end

  def page_row_max
    return [(self.height - 32) / 24, 1].max
  end

  def page_item_max
    return page_row_max * @column_max
  end

  def draw_item(index)
    item = @data[index]
    case item
    when RPG::Item
      number = $game_party.item_number(item.id)
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
    if item.price <= $game_party.gold and number < 99
      self.contents.font.color = normal_color
    else
      self.contents.font.color = disabled_color
    end
    x = 0
    y = index * 24
    rect = Rect.new(x, y, self.width - 32, 24)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    self.contents.font.name = ["Noto Sans CJK SC"]
    self.contents.font.size = 16
    self.contents.draw_text(x, y, 260, 24, item.name, 0)
    self.contents.draw_text(x + 300, y, 100, 24, item.price.to_s, 2)
  end
end




class Window_ShopSell
  alias tj_shop_sell_initialize initialize

  def initialize
    tj_shop_sell_initialize
    self.height = 320
  end

  def page_row_max
    return [(self.height - 32) / 24, 1].max
  end

  def page_item_max
    return page_row_max * @column_max
  end
end

module TianJiangShopHelpLayout
  SHOP_HELP_X = 200
  SHOP_HELP_Y = 320
  SHOP_HELP_W = 430
  SHOP_HELP_H = 140

  def set_text(data)
    tj_shop_layout
    @data = data
    description = ""
    footer = []
    case data
    when RPG::Item
      description = data.description
      footer << "价格 #{data.price}"
      footer << "范围 #{TianJiangUIFixes::SCOPE_NAMES[data.scope] || "特殊"}"
      footer << "HP+#{data.recover_hp}" if data.recover_hp != 0
      footer << "SP+#{data.recover_sp}" if data.recover_sp != 0
      footer << "永久属性+#{data.parameter_points}" if data.parameter_type != 0
      footer << "附加#{tj_shop_state_names(data.plus_state_set)}" unless data.plus_state_set.empty?
      footer << "解除#{tj_shop_state_names(data.minus_state_set)}" unless data.minus_state_set.empty?
    when RPG::Weapon
      description = data.description
      footer << "价格 #{data.price}"
      footer << "攻击+#{data.atk}"
      footer << "物防+#{data.pdef}" if data.pdef != 0
      footer << "仙防+#{data.mdef}" if data.mdef != 0
      footer << "力量+#{data.str_plus}" if data.str_plus != 0
      footer << "灵巧+#{data.dex_plus}" if data.dex_plus != 0
      footer << "速度+#{data.agi_plus}" if data.agi_plus != 0
      footer << "灵力+#{data.int_plus}" if data.int_plus != 0
    when RPG::Armor
      description = data.description
      footer << "价格 #{data.price}"
      footer << "物防+#{data.pdef}" if data.pdef != 0
      footer << "仙防+#{data.mdef}" if data.mdef != 0
      footer << "力量+#{data.str_plus}" if data.str_plus != 0
      footer << "灵巧+#{data.dex_plus}" if data.dex_plus != 0
      footer << "速度+#{data.agi_plus}" if data.agi_plus != 0
      footer << "灵力+#{data.int_plus}" if data.int_plus != 0
    when RPG::Skill
      description = data.description
      footer << "消耗#{data.sp_cost}真气"
      footer << "范围#{TianJiangUIFixes::SCOPE_NAMES[data.scope] || "特殊"}"
    else
      if data.respond_to?(:description)
        description = data.description.to_s
        footer << "价格 #{data.price}" if data.respond_to?(:price)
        footer << "攻击+#{data.atk}" if data.respond_to?(:atk) && data.atk != 0
        footer << "物防+#{data.pdef}" if data.respond_to?(:pdef) && data.pdef != 0
        footer << "仙防+#{data.mdef}" if data.respond_to?(:mdef) && data.mdef != 0
      else
        description = data.to_s
      end
    end
    key = [data.class, data.respond_to?(:id) ? data.id : nil, description.to_s, footer.join("｜")]
    return if @tj_shop_help_key == key && self.contents
    @tj_shop_help_key = key
    tj_shop_draw(description.to_s, footer.join("｜"))
  end

  def tj_shop_layout
    self.x = SHOP_HELP_X
    self.y = SHOP_HELP_Y
    self.width = SHOP_HELP_W
    self.height = SHOP_HELP_H
    unless @tj_shop_help_ready
      self.contents = Bitmap.new(self.width - 32, self.height - 32)
      @tj_shop_help_ready = true
    end
  end

  def tj_shop_draw(description, footer)
    self.contents.clear
    self.contents.font.name = ["Noto Sans CJK SC"]
    self.contents.font.color = normal_color
    self.contents.font.size = 18
    lines = tj_shop_wrap(description, self.contents.width - 8).first(3)
    lines.each_with_index do |line, i|
      self.contents.draw_text(4, 2 + i * 22, self.contents.width - 8, 22, line, 0)
    end
    foot_lines = tj_shop_wrap(footer, self.contents.width - 8).first(2)
    self.contents.font.size = 13
    fy = 2 + lines.size * 22 + 2
    foot_lines.each_with_index do |line, i|
      self.contents.draw_text(4, fy + i * 15, self.contents.width - 8, 15, line, 0)
    end
    self.visible = true
  end

  def tj_shop_wrap(text, width)
    lines = []
    line = ""
    text.to_s.each_char do |ch|
      if ch == "\n"
        lines << line
        line = ""
      elsif self.contents.text_size(line + ch).width <= width
        line += ch
      else
        lines << line unless line.empty?
        line = ch
      end
    end
    lines << line unless line.empty?
    lines
  end

  def tj_shop_state_names(ids, limit = 3)
    names = ids.map { |id| $data_states[id] ? $data_states[id].name : nil }.compact
    text = names.first(limit).join("/")
    text += "等" if names.size > limit
    text
  end
end

Window_HelpShop.prepend(TianJiangShopHelpLayout) if defined?(Window_HelpShop)
Window_Helpbuy.prepend(TianJiangShopHelpLayout) if defined?(Window_Helpbuy)

class Window_Skill
  alias tj_ui_update_help update_help
  def update_help
    if @help_window
      skill = self.skill
      @help_window.set_text(skill ? TianJiangUIFixes.skill_description(skill, @actor) : "")
    end
  end
end
