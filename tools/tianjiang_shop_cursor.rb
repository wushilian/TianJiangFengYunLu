# The custom shop lists in TianJiangUIFixes use 24px rows, but the default
# Window_Selectable cursor is 32px tall and advances by 32px per row.
# Override it for the shop windows so the highlight stays on the text.
module TianJiangShopCursor24
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
    cursor_width = self.width - 32
    self.cursor_rect.set(0, row * 24 - self.oy, cursor_width, 24)
  end
end

class Window_ShopBuy
  include TianJiangShopCursor24
end

class Window_ShopSell
  include TianJiangShopCursor24
end
