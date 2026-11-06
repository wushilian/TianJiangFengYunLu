#==============================================================================
# ■ 张小凡彩蛋 / WuXia Easter Egg
#------------------------------------------------------------------------------
# 每张地图入口附近出现“张小凡”。每张地图只能领取一次。
# 奖励顺序 3 -> 2 -> 1：
#   3 = 自创技能（优先未学会；全部学完后给最大生命/法力）
#   2 = 随机永久属性 +5（无上限）
#   1 = 银两 +10000
#==============================================================================

module WuxiaEasterEggs
  NPC_NAME = "张小凡"
  NPC_SPRITE = "郑明"
  ATTR_REWARD = 5
  HP_REWARD = 100
  MP_REWARD = 50
  # 每张大地图出现张小凡的概率；同一张地图只出现一次。
  SPAWN_CHANCE = 0.12
  # 全局最多出现次数。
  MAX_SPAWNS = 50
  # 彩蛋技能强度修正：整体降低基础威力/属性系数/吸血比例。
  SKILL_POWER_SCALE = 0.60
  SKILL_COEF_SCALE = 0.75
  SKILL_LIFESTEAL_SCALE = 0.50

  # 必须和状态画面的实际显示一致：
  # 攻击 = atk, 防御 = pdef, 幸运 = dex, 身法 = agi, 灵力 = int。
  # 原来的“力量/灵巧/速度”在状态画面里看不到（力量只参与伤害公式），
  # 所以会造成“张小凡给的属性和实际人物属性对不上”。
  STAT_NAMES = {
    :atk => "攻击",
    :pdef => "防御",
    :dex => "幸运",
    :agi => "身法",
    :int => "灵力"
  }
  STAT_POOL = [:atk, :pdef, :dex, :agi, :int]

  # id 必须接在原有技能之后：原版最大技能 ID 是 160，这里使用 161-184。
  SKILL_DEFS = [
    { :id => 161, :name => "墨影剑法", :desc => "对单体造成暗属性伤害，伤害较高；并回复造成伤害20%的生命。消耗20真气。",
      :icon => "JQJ", :proto => 81, :scope => 1, :power => 160, :atk_f => 100, :int_f => 60,
      :sp => 20, :element => [8], :plus => [], :minus => [], :variance => 15, :lifesteal => 0.20 },
    { :id => 162, :name => "流云掌", :desc => "对单体造成风属性伤害，伤害中等；有概率使目标眩晕。消耗12真气。",
      :icon => "FGPZ", :proto => 81, :scope => 1, :power => 110, :atk_f => 80, :int_f => 80,
      :sp => 12, :element => [6], :plus => [2], :minus => [], :variance => 15 },
    { :id => 163, :name => "玄阴指", :desc => "对单体造成暗属性伤害，伤害中等；有概率使目标中毒。消耗16真气。",
      :icon => "XYW", :proto => 85, :scope => 1, :power => 130, :atk_f => 0, :int_f => 100,
      :sp => 16, :element => [8], :plus => [3], :minus => [], :variance => 15 },
    { :id => 164, :name => "惊鸿步", :desc => "提升自身闪避，持续一段时间。消耗10真气。",
      :icon => "XLZS", :proto => 56, :scope => 7, :power => 0, :atk_f => 0, :int_f => 0,
      :sp => 10, :element => [], :plus => [24], :minus => [], :variance => 0 },
    { :id => 165, :name => "金钟护体", :desc => "为自身张开屏障，减少受到的伤害。消耗14真气。",
      :icon => "HXS", :proto => 54, :scope => 7, :power => 0, :atk_f => 0, :int_f => 0,
      :sp => 14, :element => [], :plus => [14], :minus => [], :variance => 0 },
    { :id => 166, :name => "回风拂柳", :desc => "恢复全体友方生命，恢复量随灵力提升，并附加持续回血。消耗22真气。",
      :icon => "QLS", :proto => 83, :scope => 4, :power => -200, :atk_f => 0, :int_f => 100,
      :sp => 22, :element => [], :plus => [26], :minus => [], :variance => 0 },
    { :id => 167, :name => "飞花摘叶", :desc => "对全体敌人造成风属性伤害，并有概率使其中毒。消耗24真气。",
      :icon => "XSFW", :proto => 84, :scope => 2, :power => 120, :atk_f => 100, :int_f => 100,
      :sp => 24, :element => [6], :plus => [3], :minus => [], :variance => 20 },
    { :id => 168, :name => "醉八仙", :desc => "对全体敌人造成伤害，伤害波动较大，并有概率使目标混乱。消耗26真气。",
      :icon => "CCWS", :proto => 57, :scope => 2, :power => 180, :atk_f => 120, :int_f => 100,
      :sp => 26, :element => [], :plus => [6], :minus => [], :variance => 40 },
    { :id => 169, :name => "天罡诀", :desc => "提升自身攻击。消耗18真气。",
      :icon => "TJZJ", :proto => 53, :scope => 7, :power => 0, :atk_f => 0, :int_f => 0,
      :sp => 18, :element => [], :plus => [17], :minus => [], :variance => 0 },
    { :id => 170, :name => "龟息功", :desc => "获得持续回血效果。消耗20真气。",
      :icon => "GMJF", :proto => 54, :scope => 7, :power => 0, :atk_f => 0, :int_f => 0,
      :sp => 20, :element => [], :plus => [26], :minus => [], :variance => 0 },
    { :id => 171, :name => "毒经", :desc => "对单体造成暗属性伤害，使目标中毒，并吸取其30点真气。消耗16真气。",
      :icon => "MJL", :proto => 85, :scope => 1, :power => 100, :atk_f => 0, :int_f => 100,
      :sp => 16, :element => [8], :plus => [3], :minus => [], :variance => 15, :sp_drain => 30 },
    { :id => 172, :name => "御风术", :desc => "提升自身闪避，持续一段时间。消耗20真气。",
      :icon => "zhuifeng", :proto => 56, :scope => 7, :power => 0, :atk_f => 0, :int_f => 0,
      :sp => 20, :element => [], :plus => [24], :minus => [], :variance => 0 },
    { :id => 173, :name => "无相劫指", :desc => "对单体造成高额暗属性伤害，伤害主要随灵力提升。消耗26真气。",
      :icon => "SJHY", :proto => 99, :scope => 1, :power => 200, :atk_f => 0, :int_f => 100,
      :sp => 26, :element => [8], :plus => [], :minus => [], :variance => 10 },
    { :id => 174, :name => "太虚剑意", :desc => "对全体敌人造成暗属性伤害，并有概率使目标沉默。消耗30真气。",
      :icon => "ZMZQ", :proto => 97, :scope => 2, :power => 180, :atk_f => 100, :int_f => 100,
      :sp => 30, :element => [8], :plus => [5], :minus => [], :variance => 20 },
    { :id => 175, :name => "寒江独钓", :desc => "对单体造成高额冰属性伤害，并有概率使目标麻痹。消耗24真气。",
      :icon => "FMZ", :proto => 94, :scope => 1, :power => 220, :atk_f => 100, :int_f => 100,
      :sp => 24, :element => [2], :plus => [8], :minus => [], :variance => 15 },
    { :id => 176, :name => "万剑归宗", :desc => "对全体敌人造成高额伤害。消耗36真气。",
      :icon => "WXWL", :proto => 97, :scope => 2, :power => 240, :atk_f => 120, :int_f => 100,
      :sp => 36, :element => [], :plus => [], :minus => [], :variance => 20 },
    { :id => 177, :name => "血战八方", :desc => "对全体敌人造成伤害，并回复造成伤害30%的生命。消耗32真气。",
      :icon => "XLJJ", :proto => 84, :scope => 2, :power => 190, :atk_f => 110, :int_f => 100,
      :sp => 32, :element => [], :plus => [], :minus => [], :variance => 25, :lifesteal => 0.30 },
    { :id => 178, :name => "破军式", :desc => "对单体造成高额伤害，并有概率使目标眩晕。消耗22真气。",
      :icon => "SHS", :proto => 99, :scope => 1, :power => 250, :atk_f => 120, :int_f => 100,
      :sp => 22, :element => [], :plus => [2], :minus => [], :variance => 15 },
    { :id => 179, :name => "凌波微步", :desc => "提升自身闪避，持续一段时间。消耗12真气。",
      :icon => "YJFX", :proto => 56, :scope => 7, :power => 0, :atk_f => 0, :int_f => 0,
      :sp => 12, :element => [], :plus => [24], :minus => [], :variance => 0 },
    { :id => 180, :name => "静心诀", :desc => "恢复全体友方生命，并解除眩晕、中毒等大部分负面状态。消耗20真气。",
      :icon => "YJS", :proto => 83, :scope => 4, :power => -150, :atk_f => 0, :int_f => 100,
      :sp => 20, :element => [], :plus => [], :minus => [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 18], :variance => 0 },
    { :id => 181, :name => "一阳指", :desc => "对单体造成光属性伤害，并有概率使目标眩晕。消耗20真气。",
      :icon => "GYSF", :proto => 94, :scope => 1, :power => 180, :atk_f => 100, :int_f => 100,
      :sp => 20, :element => [7], :plus => [2], :minus => [], :variance => 10 },
    { :id => 182, :name => "玄冰掌", :desc => "对单体造成冰属性伤害，并有概率使目标麻痹。消耗18真气。",
      :icon => "FHLDZ", :proto => 94, :scope => 1, :power => 150, :atk_f => 80, :int_f => 100,
      :sp => 18, :element => [2], :plus => [8], :minus => [], :variance => 15 },
    { :id => 183, :name => "破空剑气", :desc => "对全体敌人造成高额伤害。消耗28真气。",
      :icon => "CLS", :proto => 97, :scope => 2, :power => 200, :atk_f => 100, :int_f => 100,
      :sp => 28, :element => [], :plus => [], :minus => [], :variance => 20 },
    { :id => 184, :name => "九阳护体", :desc => "获得持续回血，并提升自身防御。消耗24真气。",
      :icon => "ZQLB", :proto => 54, :scope => 7, :power => 0, :atk_f => 0, :int_f => 0,
      :sp => 24, :element => [], :plus => [26, 19], :minus => [], :variance => 0 }
  ]

  # 降低彩蛋技能强度；提示/说明窗口读取的也是同一份定义。
  SKILL_DEFS.each do |d|
    d[:power] = (d[:power] * SKILL_POWER_SCALE).to_i
    d[:atk_f] = (d[:atk_f] * SKILL_COEF_SCALE).to_i
    d[:int_f] = (d[:int_f] * SKILL_COEF_SCALE).to_i
    d[:lifesteal] = d[:lifesteal] * SKILL_LIFESTEAL_SCALE if d[:lifesteal]
  end

  SKILL_BY_ID = {}
  SKILL_DEFS.each { |d| SKILL_BY_ID[d[:id]] = d }

  # 无极派婆婆的隐藏战斗奖励：最大法力（SP）每次 +5，累计最多 +500。
  MANA_REWARD = 5
  MANA_REWARD_CAP = 500

  def self.give_mana_reward(amount = MANA_REWARD)
    return if $game_party == nil
    actor = $game_party.actors[0]
    return if actor == nil
    var = :@mkxp_wuxia_sp_bonus
    current = actor.instance_variable_get(var) || 0
    return if current >= MANA_REWARD_CAP
    add = [amount.to_i, MANA_REWARD_CAP - current].min
    return if add <= 0
    actor.instance_variable_set(var, current + add)
    actor.sp = [actor.sp + add, actor.maxsp].min
  end

  def self.after_popo_battle
    give_mana_reward(MANA_REWARD)
    # 输掉时全队会处于战斗不能状态，回满一次避免卡在地图
    if $game_party != nil and $game_party.respond_to?(:all_dead?) and $game_party.all_dead?
      $game_party.actors.each do |actor|
        actor.hp = actor.maxhp
        actor.sp = actor.maxsp
      end
    end
  end

  module_function

  def available_skill_ids
    return [] unless $data_skills
    SKILL_DEFS.map { |d| d[:id] }.select { |id| $data_skills[id] }
  end

  def ensure_skills
    return if @skills_created
    return if $data_skills.nil?
    base_proto = $data_skills[83] || $data_skills[57]
    SKILL_DEFS.each do |d|
      id = d[:id]
      s = $data_skills[id]
      unless s
        proto = $data_skills[d[:proto]] || base_proto
        next if proto.nil?
        s = proto.dup
      end
      begin
        s.instance_variable_set(:@id, id)
        s.instance_variable_set(:@name, d[:name])
        s.instance_variable_set(:@description, d[:desc])
        s.instance_variable_set(:@icon_name, d[:icon])
        s.instance_variable_set(:@scope, d[:scope])
        s.instance_variable_set(:@sp_cost, d[:sp])
        s.instance_variable_set(:@power, d[:power])
        s.instance_variable_set(:@atk_f, d[:atk_f])
        s.instance_variable_set(:@int_f, d[:int_f])
        s.instance_variable_set(:@str_f, 0)
        s.instance_variable_set(:@dex_f, 0)
        s.instance_variable_set(:@agi_f, 0)
        s.instance_variable_set(:@pdef_f, 0)
        s.instance_variable_set(:@mdef_f, 0)
        s.instance_variable_set(:@eva_f, 0)
        s.instance_variable_set(:@hit, 100)
        s.instance_variable_set(:@variance, d[:variance] || 0)
        s.instance_variable_set(:@element_set, d[:element] || [])
        s.instance_variable_set(:@plus_state_set, d[:plus] || [])
        s.instance_variable_set(:@minus_state_set, d[:minus] || [])
        s.instance_variable_set(:@common_event_id, 0)
        s.instance_variable_set(:@occasion, 0)
        $data_skills[id] = s
      rescue Exception
        # 单个技能创建失败不影响其他技能
      end
    end
    @skills_created = true
  end

  def map_order(map_id)
    info = $data_mapinfos ? $data_mapinfos[map_id] : nil
    order = info ? info.order : 0
    order = map_id if order.nil? || order <= 0
    order
  end

  def map_kind(map_id)
    map_order(map_id) % 2 == 1 ? 3 : 2
  end

  def add_stat(actor, stat, amount)
    var = "@mkxp_wuxia_#{stat}_bonus"
    old = actor.instance_variable_get(var) || 0
    actor.instance_variable_set(var, old + amount)
  end

  def apply_hp_mp(actor)
    hp_var = :@mkxp_wuxia_hp_bonus
    sp_var = :@mkxp_wuxia_sp_bonus
    actor.instance_variable_set(hp_var, (actor.instance_variable_get(hp_var) || 0) + HP_REWARD)
    actor.instance_variable_set(sp_var, (actor.instance_variable_get(sp_var) || 0) + MP_REWARD)
    actor.hp = [actor.hp + HP_REWARD, actor.maxhp].min
    actor.sp = [actor.sp + MP_REWARD, actor.maxsp].min
  end

  def show_message(text)
    $game_temp.message_text = text
    $game_temp.message_proc = Proc.new { }
  end

  def remove_npc(scene)
    sprite = scene.instance_variable_get(:@mkxp_wuxia_sprite)
    spriteset = scene.instance_variable_get(:@spriteset)
    if sprite
      list = spriteset ? spriteset.instance_variable_get(:@character_sprites) : nil
      list.delete(sprite) if list
      sprite.dispose
    end
    scene.instance_variable_set(:@mkxp_wuxia_npc, nil)
    scene.instance_variable_set(:@mkxp_wuxia_sprite, nil)
  end

  def claim_reward(scene, map_id)
    claimed = $game_system.mkxp_wuxia_claimed ||= {}
    return if claimed[map_id]
    actor = $game_party.actors[0]
    return if actor.nil?

    kind = map_kind(map_id)
    text = nil

    if kind == 3
      unlearned = available_skill_ids.reject { |id| actor.skill_learn?(id) }
      if unlearned.empty?
        apply_hp_mp(actor)
        text = "张小凡：我的武学已经尽数传你。\n再送你一口真气：最大生命 +#{HP_REWARD}，最大法力 +#{MP_REWARD}。"
      else
        skill_id = unlearned[rand(unlearned.size)]
        defn = SKILL_BY_ID[skill_id]
        if defn
          actor.learn_skill(skill_id)
          text = "张小凡：你我有缘，这门「#{defn[:name]}」便传给你。\n#{defn[:desc]}"
        else
          apply_hp_mp(actor)
          text = "张小凡：武学有尽，真气无穷。\n最大生命 +#{HP_REWARD}，最大法力 +#{MP_REWARD}。"
        end
      end
    elsif kind == 2
      stat = STAT_POOL[rand(STAT_POOL.size)]
      add_stat(actor, stat, ATTR_REWARD)
      text = "张小凡：我替你推宫过血。\n#{STAT_NAMES[stat]}永久 +#{ATTR_REWARD}。"
    else
      $game_party.gain_gold(GOLD_REWARD)
      text = "张小凡：这些银两拿去，江湖路远。\n获得 #{GOLD_REWARD} 文。"
    end

    claimed[map_id] = true
    $game_system.mkxp_wuxia_spawn_count =
      ($game_system.mkxp_wuxia_spawn_count || 0) + 1
    remove_npc(scene)
    begin
      $game_system.se_play($data_system.decision_se)
    rescue Exception
    end
    show_message(text.to_s)
  end

  def find_npc_position
    px = $game_player.x
    py = $game_player.y
    (1..6).each do |r|
      offsets = [
        [0, r], [r, 0], [0, -r], [-r, 0],
        [r, r], [r, -r], [-r, r], [-r, -r]
      ]
      offsets.each do |dx, dy|
        x = px + dx
        y = py + dy
        next if x < 0 || y < 0 || x >= $game_map.width || y >= $game_map.height
        next if x == px && y == py
        next unless $game_map.passable?(x, y, 2)
        occupied = false
        $game_map.events.each_value do |event|
          if event.x == x && event.y == y
            occupied = true
            break
          end
        end
        next if occupied
        return [x, y]
      end
    end
    nil
  end

  def near_player?(npc)
    dx = npc.x - $game_player.x
    dy = npc.y - $game_player.y
    return true if dx == 0 && dy == 0
    return false unless dx.abs + dy.abs == 1
    case $game_player.direction
    when 2 then dx == 0 && dy == 1
    when 4 then dx == -1 && dy == 0
    when 6 then dx == 1 && dy == 0
    when 8 then dx == 0 && dy == -1
    else false
    end
  end

  def spawn_npc(scene, spriteset)
    return if $game_map.width < 30 or $game_map.height < 20
    pos = find_npc_position
    pos = [$game_player.x, $game_player.y] if pos.nil?
    npc = MkxpWuxiaNpc.new(pos[0], pos[1])
    viewport = spriteset.instance_variable_get(:@viewport1)
    list = spriteset.instance_variable_get(:@character_sprites)
    return if list.nil?
    sprite = Sprite_Character.new(viewport, npc)
    list.push(sprite)
    scene.instance_variable_set(:@mkxp_wuxia_npc, npc)
    scene.instance_variable_set(:@mkxp_wuxia_sprite, sprite)
    scene.instance_variable_set(:@mkxp_wuxia_initialized, true)
  end

  def after_map_update(scene)
    return if $game_map.nil? || $game_player.nil? || $game_system.nil?
    ensure_skills

    spriteset = scene.instance_variable_get(:@spriteset)
    return if spriteset.nil?
    map_id = $game_map.map_id

    if scene.instance_variable_get(:@mkxp_wuxia_map_id) != map_id ||
       scene.instance_variable_get(:@mkxp_wuxia_spriteset) != spriteset
      scene.instance_variable_set(:@mkxp_wuxia_map_id, map_id)
      scene.instance_variable_set(:@mkxp_wuxia_spriteset, spriteset)
      scene.instance_variable_set(:@mkxp_wuxia_initialized, false)
      scene.instance_variable_set(:@mkxp_wuxia_attempted, false)
      scene.instance_variable_set(:@mkxp_wuxia_npc, nil)
      scene.instance_variable_set(:@mkxp_wuxia_sprite, nil)
    end

    claimed = $game_system.mkxp_wuxia_claimed ||= {}
    return if claimed[map_id]
    # 只在大地图上尝试出现
    return if $game_map.width < 30 or $game_map.height < 20

    count = $game_system.mkxp_wuxia_spawn_count
    # 旧存档没有计数时，用已领取地图数作为起点
    count = claimed.size if count.nil? or (count == 0 and !claimed.empty?)
    # 旧存档（脚本更新前创建）读档时不会走 Game_System#initialize，
    # 这里必须兜底为 0，否则 count >= MAX_SPAWNS 会对 nil 报错并卡死地图。
    count = 0 if count.nil?
    $game_system.mkxp_wuxia_spawn_count = count
    return if count >= MAX_SPAWNS

    unless scene.instance_variable_get(:@mkxp_wuxia_initialized)
      # 每次进入地图只判定一次；失败后离开再进才会重新判定。
      # 如果出现了但没有领取，下次进入仍视为“没出现过”，继续判定。
      return if scene.instance_variable_get(:@mkxp_wuxia_attempted)
      scene.instance_variable_set(:@mkxp_wuxia_attempted, true)
      return unless rand < SPAWN_CHANCE
      spawn_npc(scene, spriteset)
    end

    npc = scene.instance_variable_get(:@mkxp_wuxia_npc)
    return if npc.nil?
    return if $game_temp.message_window_showing
    if $game_system.map_interpreter && $game_system.map_interpreter.running?
      return
    end
    return unless Input.trigger?(Input::C)
    return unless near_player?(npc)

    claim_reward(scene, map_id)
  end

  def apply_skill_extras(target, user, skill, result)
    return unless result && skill
    id = skill.id
    return if id.nil?
    defn = SKILL_BY_ID[id]
    return if defn.nil?
    damage = target.damage
    return unless damage.is_a?(Numeric) && damage > 0

    if defn[:lifesteal]
      heal = (damage * defn[:lifesteal]).to_i
      if heal > 0 && user.respond_to?(:hp) && user.respond_to?(:maxhp)
        user.hp = [user.hp + heal, user.maxhp].min
      end
    end

    if defn[:sp_drain]
      amount = defn[:sp_drain].to_i
      if amount > 0 && user.respond_to?(:sp) && user.respond_to?(:maxsp)
        user.sp = [user.sp + amount, user.maxsp].min
      end
      if amount > 0 && target.respond_to?(:sp) && target.respond_to?(:sp=)
        target.sp = [target.sp - amount, 0].max
      end
    end
  end
end

#------------------------------------------------------------------------------
# 属性/生命/法力永久加成
#------------------------------------------------------------------------------
class Game_Actor
  alias_method :__mkxp_wuxia_base_maxhp, :base_maxhp unless method_defined?(:__mkxp_wuxia_base_maxhp)
  alias_method :__mkxp_wuxia_base_maxsp, :base_maxsp unless method_defined?(:__mkxp_wuxia_base_maxsp)
  alias_method :__mkxp_wuxia_base_str, :base_str unless method_defined?(:__mkxp_wuxia_base_str)
  alias_method :__mkxp_wuxia_base_dex, :base_dex unless method_defined?(:__mkxp_wuxia_base_dex)
  alias_method :__mkxp_wuxia_base_agi, :base_agi unless method_defined?(:__mkxp_wuxia_base_agi)
  alias_method :__mkxp_wuxia_base_int, :base_int unless method_defined?(:__mkxp_wuxia_base_int)
  alias_method :__mkxp_wuxia_base_atk, :base_atk unless method_defined?(:__mkxp_wuxia_base_atk)
  alias_method :__mkxp_wuxia_base_pdef, :base_pdef unless method_defined?(:__mkxp_wuxia_base_pdef)

  def base_maxhp
    __mkxp_wuxia_base_maxhp + (@mkxp_wuxia_hp_bonus || 0)
  end

  def base_maxsp
    __mkxp_wuxia_base_maxsp + (@mkxp_wuxia_sp_bonus || 0)
  end

  def base_str
    __mkxp_wuxia_base_str + (@mkxp_wuxia_str_bonus || 0)
  end

  def base_dex
    __mkxp_wuxia_base_dex + (@mkxp_wuxia_dex_bonus || 0)
  end

  def base_agi
    __mkxp_wuxia_base_agi + (@mkxp_wuxia_agi_bonus || 0)
  end

  def base_int
    __mkxp_wuxia_base_int + (@mkxp_wuxia_int_bonus || 0)
  end

  def base_atk
    __mkxp_wuxia_base_atk + (@mkxp_wuxia_atk_bonus || 0)
  end

  def base_pdef
    __mkxp_wuxia_base_pdef + (@mkxp_wuxia_pdef_bonus || 0)
  end
end

#------------------------------------------------------------------------------
# 存档中的领取记录
#------------------------------------------------------------------------------
class Game_System
  attr_accessor :mkxp_wuxia_claimed unless method_defined?(:mkxp_wuxia_claimed)
  attr_accessor :mkxp_wuxia_spawned unless method_defined?(:mkxp_wuxia_spawned)
  attr_accessor :mkxp_wuxia_spawned_map unless method_defined?(:mkxp_wuxia_spawned_map)
  attr_accessor :mkxp_wuxia_spawn_count unless method_defined?(:mkxp_wuxia_spawn_count)
  attr_accessor :mkxp_wuxia_spawned_maps unless method_defined?(:mkxp_wuxia_spawned_maps)
  attr_accessor :mkxp_wuxia_rolled unless method_defined?(:mkxp_wuxia_rolled)
  alias_method :__mkxp_wuxia_initialize, :initialize unless method_defined?(:__mkxp_wuxia_initialize)

  def initialize
    __mkxp_wuxia_initialize
    @mkxp_wuxia_claimed ||= {}
    @mkxp_wuxia_spawned = false if @mkxp_wuxia_spawned.nil?
    @mkxp_wuxia_spawn_count ||= 0
    @mkxp_wuxia_spawned_maps ||= {}
    @mkxp_wuxia_rolled ||= {}
  end
end

#------------------------------------------------------------------------------
# 地图画面注入
#------------------------------------------------------------------------------
class Scene_Map
  alias_method :__mkxp_wuxia_update, :update unless method_defined?(:__mkxp_wuxia_update)

  def update
    __mkxp_wuxia_update
    WuxiaEasterEggs.after_map_update(self)
  end
end

#------------------------------------------------------------------------------
# 战斗自定义效果
#------------------------------------------------------------------------------
module MkxpWuxiaBattleExtras
  def skill_effect(user, skill)
    result = super
    WuxiaEasterEggs.apply_skill_extras(self, user, skill, result)
    result
  end
end
Game_Battler.prepend(MkxpWuxiaBattleExtras) unless Game_Battler.ancestors.include?(MkxpWuxiaBattleExtras)

#------------------------------------------------------------------------------
# 张小凡的地图角色
#------------------------------------------------------------------------------
class MkxpWuxiaNpc < Game_Character
  def initialize(x, y)
    super()
    @x = x
    @y = y
    @real_x = x * 128
    @real_y = y * 128
    @tile_id = 0
    @character_name = WuxiaEasterEggs::NPC_SPRITE
    @character_hue = 0
    @direction = 2
    @pattern = 0
    @opacity = 255
    @blend_type = 0
    @transparent = false
    @step_anime = false
    @animation_id = 0
    @priority_type = 1
    @through = false
    @move_speed = 3
    @move_frequency = 3
  end
end
