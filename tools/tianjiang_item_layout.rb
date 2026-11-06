# Item list layout (menu + battle) and battle item/skill window separation.
#
# 1. Window_Item / Window_Item2 used 4 narrow columns: the item name was drawn
#    with a 160px box while the quantity was drawn at x + 104, so long names
#    overlapped the quantity. Use 2 wide columns and align the cursor.
# 2. In battle, starting skill selection did not hide the item window/help,
#    so item text could stay visible over the skill window. Hide the other
#    mode's windows when switching.

class Window_Item
  alias tj_item_layout_init initialize

  def initialize
    tj_item_layout_init
    @column_max = 2
    # 物品窗原高 384，底部一行会被帮助窗盖住；缩到 352。
    self.height = 352
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
    return if item == nil
    case item
    when RPG::Item
      number = $game_party.item_number(item.id)
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
    if item.is_a?(RPG::Item) and $game_party.item_can_use?(item.id)
      self.contents.font.color = normal_color
    else
      self.contents.font.color = disabled_color
    end
    cell = (self.width - 32) / @column_max
    x = index % @column_max * cell
    y = index / @column_max * 24
    self.contents.fill_rect(Rect.new(x, y, cell - 4, 24), Color.new(0, 0, 0, 0))
    self.contents.font.size = 16
    self.contents.draw_text(x + 4, y, cell - 84, 24, item.name, 0)
    self.contents.draw_text(x + cell - 40, y, 36, 24, number.to_s, 2)
  end

  def update_cursor_rect
    if @index < 0
      self.cursor_rect.empty
      return
    end
    row = @index / @column_max
    if row < self.top_row
      self.top_row = row
    end
    if row > self.top_row + (self.page_row_max - 1)
      self.top_row = row - (self.page_row_max - 1)
    end
    cell = (self.width - 32) / @column_max
    x = @index % @column_max * cell
    y = row * 24 - self.oy
    self.cursor_rect.set(x, y, cell - 4, 24)
  end
end

class Window_Item2
  alias tj_item_layout_init2 initialize

  def initialize
    tj_item_layout_init2
    @column_max = 2
    self.height = 352
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
    return if item == nil
    case item
    when RPG::Item
      number = $game_party.item_number(item.id)
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
    if item.is_a?(RPG::Item) and $game_party.item_can_use?(item.id)
      self.contents.font.color = normal_color
    else
      self.contents.font.color = disabled_color
    end
    cell = (self.width - 32) / @column_max
    x = index % @column_max * cell
    y = index / @column_max * 24
    self.contents.fill_rect(Rect.new(x, y, cell - 4, 24), Color.new(0, 0, 0, 0))
    self.contents.font.size = 16
    self.contents.draw_text(x + 4, y, cell - 84, 24, item.name, 0)
    self.contents.draw_text(x + cell - 40, y, 36, 24, number.to_s, 2)
  end

  def update_cursor_rect
    if @index < 0
      self.cursor_rect.empty
      return
    end
    row = @index / @column_max
    if row < self.top_row
      self.top_row = row
    end
    if row > self.top_row + (self.page_row_max - 1)
      self.top_row = row - (self.page_row_max - 1)
    end
    cell = (self.width - 32) / @column_max
    x = @index % @column_max * cell
    y = row * 24 - self.oy
    self.cursor_rect.set(x, y, cell - 4, 24)
  end
end

class Scene_Battle
  alias tj_item_layout_start_skill start_skill_select

  def start_skill_select
    begin
      if @item_window != nil
        @item_window.visible = false
        @item_window.active = false
      end
      @help2_window.visible = false if @help2_window != nil
      @itemicon_window.visible = false if @itemicon_window != nil
    rescue Exception
    end
    tj_item_layout_start_skill
    begin
      @status_window.visible = false if @status_window != nil
    rescue Exception
    end
  end

  alias tj_item_layout_start_item start_item_select

  def start_item_select
    begin
      if @skill_window != nil
        @skill_window.visible = false
        @skill_window.active = false
      end
      @help3_window.visible = false if @help3_window != nil
      @touxiang_window.visible = false if @touxiang_window != nil
    rescue Exception
    end
    tj_item_layout_start_item
  end
end
