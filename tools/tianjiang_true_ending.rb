module TianJiangTrueEnding
  TEXT_OVERRIDES = {
    25 => {
      "无上神功，你不会怪罪贫道将你逐出师门吧？" =>
        "无上神功。孤梵，为师当年将你逐出师门，你可曾怪过我？",
      "怪罪师父．．" =>
        "师父，弟子从未怪过您。",
      "无极派．．" =>
        "只是紫仪她……",
      "不情之请，还望你能答应呀。" =>
        "她以圣女之血替赵梦雪挡下兽神的鬼神同归，魂魄已散。",
      "这掌门之位。" =>
        "回魂权杖、盘古神仗、苍龙剑诀，三器合一，可逆天改命。",
      "，弟子不得不就梦姐姐。" =>
        "无论什么代价，我都要把她带回来。",
      "人救活梦姐姐。" =>
        "赵梦雪还在等我。师父，弟子去了。",
      "也会选择了。为师不会为难你，你走吧．．" =>
        "你已经做出了选择。为师不会为难你，你走吧……"
    },
    121 => {
      "事了，紫怡哪去了…" =>
        "紫仪替我挡下那一击后，就再没醒过来……",
      "紫怡挡住了，今生今世算是和无极派恩怨两清" =>
        "她以魔教圣女之血替我挡下杀招，",
      "了，不知道紫怡现在怎么样了，从今以后绝不" =>
        "只是紫仪至今昏迷不醒。我发誓，此生绝不",
      "可以辜负她了。" =>
        "再负她。"
    },
    132 => {
      "我说过一定会为月影大师报仇的，现在紫怡为" =>
        "紫仪为我受了重伤，又用圣女血稳住梦姐姐的魂魄。",
      "我受了重伤，我不得不照顾她，我想先回魔教" =>
        "我先带她回魔教，再去找蝙蝠王。",
      "将紫怡带走，然后再去找蝙蝠王。" =>
        "这份恩情，我此生难还。",
      "和紫怡姑娘有情人终成眷属，我要走了…" =>
        "愿你和紫仪姑娘有情人终成眷属，我要走了……"
    },
    170 => {
      "柳紫仪：不要…………" =>
        "柳紫仪：不要——！",
      "陆孤梵：不要…" =>
        "陆孤梵：紫仪，不要——！",
      "“只见天地变色，兽神释放出各位神灵全部涌" =>
        "“兽神临死前发动鬼神同归，万千神力直取神女……”",
      "向神女…”“死一般的寂静后…………”" =>
        "“柳紫仪挡在赵梦雪身前，血染白衣……”",
      "赵梦雪：对不起！！" =>
        "赵梦雪：紫仪！你为什么这么傻……"
    }
  }

  SLIDE_COUNT = 10
  FRAMES_PER_SLIDE = 210

  def self.rewrite_text(map_id, text)
    table = TEXT_OVERRIDES[map_id]
    return text unless table && text
    table[text] || text
  end
end

module TianJiangInterpreterText
  def command_101
    if @list && @index
      map_id = $game_map ? $game_map.map_id : 0
      i = @index
      while i < @list.size && (@list[i].code == 101 || @list[i].code == 401)
        text = @list[i].parameters[0]
        @list[i].parameters[0] = TianJiangTrueEnding.rewrite_text(map_id, text)
        i += 1
      end
    end
    super
  end
end
Interpreter.prepend(TianJiangInterpreterText)

class Scene_TianJiangTrueEnding
  def main
    @sprite = Sprite.new
    @sprite.x = 0
    @sprite.y = 0
    @sprite.z = 1000
    Audio.bgm_play("Audio/BGM/FlashMusic4", 100, 100)
    Graphics.transition(40)

    i = 1
    while i <= TianJiangTrueEnding::SLIDE_COUNT
      @sprite.bitmap = RPG::Cache.picture(sprintf("TrueEnd/%02d", i))
      result = wait(TianJiangTrueEnding::FRAMES_PER_SLIDE)
      break if result == :skip_all
      i += 1
    end

    Graphics.freeze
    @sprite.bitmap = nil
    @sprite.dispose
    Audio.bgm_stop
    $scene = Scene_Title.new
  end

  def wait(frames)
    frames.times do
      Graphics.update
      Input.update
      return :skip_all if Input.trigger?(Input::B)
      return :next if Input.trigger?(Input::C)
    end
    :timeout
  end
end

class Scene_Logo21
  alias_method :tj_true_ending_original_main, :main
  def main
    Scene_TianJiangTrueEnding.new.main
  end
end
