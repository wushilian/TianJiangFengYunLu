# Skill window layout + battle HUD overlap fix.
#
# The custom skill window uses 3 narrow columns (212px) and a transparent
# background. Long skill names overlap the SP cost, and in battle the center
# Window_Status HUD (face / HP / SP) shows through the transparent skill window,
# covering skills and making the list look incomplete.
#
# Use two wide columns instead, right-align the SP cost, and hide the center
# HUD while the battle skill window is visible.

class Window_Skill
  alias tj_skill_layout_initialize initialize

  def initialize(actor)
    tj_skill_layout_initialize(actor)
    @column_max = 2
    refresh
    self.index = 0
  end

  # 内容区宽度是 width-32，旧代码用 width-8 计算列宽，
  # 第 2 列的 SP 数字会画到内容区外被窗口边框裁掉。
  def draw_item(index)
    skill = @data[index]
    if skill == nil
      return
    end
    if @actor.skill_can_use?(skill.id)
      self.contents.font.color = normal_color
    else
      self.contents.font.color = disabled_color
    end
    content_width = self.width - 32
    column_width = content_width / @column_max
    x = index % @column_max * column_width
    y = index / @column_max * 32
    rect = Rect.new(x, y, column_width - 4, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon(skill.icon_name)
    opacity = self.contents.font.color == normal_color ? 255 : 128
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)
    self.contents.font.size = 22
    self.contents.draw_text(x + 28, y, column_width - 88, 32, skill.name, 0)
    self.contents.draw_text(x + column_width - 56, y, 48, 32, skill.sp_cost.to_s, 2)
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
    content_width = self.width - 32
    column_width = content_width / @column_max
    x = @index % @column_max * column_width
    y = row * 32 - self.oy
    self.cursor_rect.set(x, y, column_width - 4, 32)
  end
end

# Window_Helpjineng 原宽 510，放在 x=160 时右边缘到 670，
# 超出 640 宽的画面，最后几个字会被裁掉。缩到 464 以完整显示。
class Window_Helpjineng
  alias tj_help_width_initialize initialize

  def initialize
    tj_help_width_initialize
    self.width = 464
    self.contents.dispose if self.contents != nil
    self.contents = Bitmap.new(self.width - 32, self.height - 32)
  end
end

class Scene_Battle
  alias tj_skill_hud_update update_phase3_skill_select

  def update_phase3_skill_select
    tj_skill_hud_update
    if @skill_window != nil
      @skill_window.opacity = 255
      @skill_window.back_opacity = 160
      @skill_window.visible = true
    end
    if @status_window != nil and @skill_window != nil and @skill_window.visible
      @status_window.visible = false
    end
  end

  alias tj_skill_hud_end end_skill_select

  def end_skill_select
    tj_skill_hud_end
    @status_window.visible = true if @status_window != nil
  end

  alias tj_skill_hud_next phase3_next_actor

  def phase3_next_actor
    tj_skill_hud_next
    @status_window.visible = true if @status_window != nil
  end
end

# 存档里可能残留空的技能 ID（例如 160），会在技能窗第一行显示成
# 一个空白格并占住光标。刷新后过滤掉名字为空的技能。
class Window_Skill
  alias tj_skill_filter_refresh refresh

  def refresh
    tj_skill_filter_refresh
    return if @data == nil
    valid = @data.reject { |s| s == nil || s.name.to_s.strip.empty? }
    return if valid.size == @data.size
    @data = valid
    @item_max = @data.size
    if self.index == nil || (self.index >= @item_max && @item_max > 0)
      self.index = 0
    end
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    if @item_max > 0
      self.contents = Bitmap.new(self.width - 32, row_max * 32)
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
end

# 菜单技能窗原本 0,128,640,352，会一直被下面的头像/说明窗盖住，
# 导致部分技能只看到说明、看不到名字。菜单里缩到 192 高（10 个/页），
# 战斗里保持原来的 256 高。
class Window_Skill
  alias tj_skill_menu_resize_initialize initialize

  def initialize(actor)
    tj_skill_menu_resize_initialize(actor)
    unless $game_temp.in_battle
      self.height = 192
      refresh
      self.index = 0
    end
  end
end
