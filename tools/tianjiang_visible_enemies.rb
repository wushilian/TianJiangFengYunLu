class VisibleEnemy < Game_Character
  attr_accessor :troop_id
  attr_accessor :in_battle

  def initialize(x, y, troop_id, sprite_name)
    super()
    @x = x
    @y = y
    @real_x = x * 128
    @real_y = y * 128
    @troop_id = troop_id
    @character_name = sprite_name
    @character_hue = 0
    @move_type = 1
    @move_speed = 2.4
    @move_frequency = 4
    @stop_count = rand(80)
    @through = true
    @in_battle = false
  end

  def passable?(x, y, d)
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    return false unless $game_map.valid?(new_x, new_y)
    return false unless $game_map.passable?(x, y, d, self)
    return false unless $game_map.passable?(new_x, new_y, 10 - d)
    return false if VisibleEnemyManager.occupied?(new_x, new_y, self)
    true
  end

  def check_event_trigger_touch(x, y)
  end

  def check_event_trigger_here(triggers)
    false
  end
end

class VisibleEnemyManager
  LIMIT = 8

  def self.check_touch
    manager = $visible_enemy_manager
    manager.check_touch if manager
  end

  def self.occupied?(x, y, except)
    manager = $visible_enemy_manager
    return false unless manager
    manager.occupied?(x, y, except)
  end

  def self.enemy_at?(x, y)
    manager = $visible_enemy_manager
    manager ? manager.enemy_at?(x, y) : false
  end

  def initialize(viewport, character_sprites)
    @viewport = viewport
    @character_sprites = character_sprites
    @enemies = []
    @active = false
    @spawn_count = 0
  end

  def setup
    @active = false
    return if $BTEST
    return if $game_party.actors.size == 0
    return if $game_system.encounter_disabled
    list = $game_map.encounter_list
    return if list.nil? or list.empty?
    area = $game_map.width * $game_map.height
    @spawn_count = 3 + area / 300
    @spawn_count = LIMIT if @spawn_count > LIMIT
    @spawn_count = 2 if @spawn_count < 2
    @active = true
    @spawn_count.times { spawn_enemy }
    $game_player.make_encounter_count
  end

  def update
    return unless @active
    return if $game_system.encounter_disabled
    @enemies.each do |enemy|
      enemy.update unless enemy.in_battle
    end
  end

  def check_touch
    return unless @active
    return if $game_system.encounter_disabled
    return if $game_temp.battle_calling
    return if $game_temp.player_transferring
    return if $game_temp.message_window_showing
    return if $game_system.map_interpreter.running?
    enemy = @enemies.find do |item|
      not item.in_battle and item.x == $game_player.x and item.y == $game_player.y
    end
    enemy = front_enemy if enemy.nil? and Input.dir4 != 0 and not $game_player.moving?
    return unless enemy
    enemy.in_battle = true
    $game_temp.battle_calling = true
    $game_temp.battle_troop_id = enemy.troop_id
    $game_temp.battle_can_escape = true
    $game_temp.battle_can_lose = false
    $game_temp.battle_proc = nil
  end

  def occupied?(x, y, except)
    @enemies.any? do |enemy|
      enemy != except and not enemy.in_battle and enemy.x == x and enemy.y == y
    end
  end

  def enemy_at?(x, y)
    @enemies.any? do |enemy|
      not enemy.in_battle and enemy.x == x and enemy.y == y
    end
  end

  def dispose
    @active = false
    @enemies.clear
  end

  private

  def front_enemy
    d = $game_player.direction
    x = $game_player.x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    y = $game_player.y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    @enemies.find do |enemy|
      not enemy.in_battle and enemy.x == x and enemy.y == y
    end
  end

  def spawn_enemy
    list = $game_map.encounter_list
    return if list.nil? or list.empty?
    troop_id = list[rand(list.size)]
    troop = $data_troops[troop_id]
    return unless troop
    spot = find_spawn_spot
    return unless spot
    enemy = VisibleEnemy.new(spot[0], spot[1], troop_id, sprite_for_troop(troop))
    @enemies.push(enemy)
    @character_sprites.push(Sprite_Character.new(@viewport, enemy))
  end

  def find_spawn_spot
    80.times do
      x = rand($game_map.width)
      y = rand($game_map.height)
      next unless spawnable?(x, y)
      return [x, y]
    end
    nil
  end

  def spawnable?(x, y)
    return false unless $game_map.valid?(x, y)
    return false unless [2, 4, 6, 8].any? { |d| $game_map.passable?(x, y, d) }
    return false if ($game_player.x - x).abs + ($game_player.y - y).abs < 4
    $game_map.events.each_value do |event|
      return false if event.x == x and event.y == y
    end
    not occupied?(x, y, nil)
  end

  def sprite_for_troop(troop)
    text = troop.name.to_s
    members = troop.members || []
    members.each do |member|
      enemy = $data_enemies[member.enemy_id]
      text += enemy.name.to_s if enemy
    end
    return "蝙蝠王" if text =~ /蝙蝠/
    return "蛇妖" if text =~ /蛇/
    return "老虎" if text =~ /虎/
    return "猪精" if text =~ /猪/
    return "兔子精" if text =~ /兔/
    return "狐狸" if text =~ /狐/
    return "盗贼" if text =~ /强盗|盗贼|流氓|贼/
    return "守卫" if text =~ /守卫|地牢|魔教|鬼|蒙面/
    return "和尚" if text =~ /少林|和尚/
    return "道士" if text =~ /道士|道观/
    "怪物"
  end
end

class Game_Player
  alias tj_visible_enemies_make_encounter_count make_encounter_count
  def make_encounter_count
    tj_visible_enemies_make_encounter_count
    @encounter_count = 999999
  end
end

class Scene_Map
  alias tj_visible_enemies_update update
  def update
    tj_visible_enemies_update
    VisibleEnemyManager.check_touch
  end
end

class Spriteset_Map
  attr_reader :character_sprites

  alias tj_visible_enemies_initialize initialize
  def initialize
    tj_visible_enemies_initialize
    @visible_enemy_manager = VisibleEnemyManager.new(@viewport1, @character_sprites)
    $visible_enemy_manager = @visible_enemy_manager
    @visible_enemy_manager.setup
  end

  alias tj_visible_enemies_update update
  def update
    @visible_enemy_manager.update if @visible_enemy_manager
    tj_visible_enemies_update
  end

  alias tj_visible_enemies_dispose dispose
  def dispose
    if @visible_enemy_manager
      @visible_enemy_manager.dispose
      @visible_enemy_manager = nil
    end
    $visible_enemy_manager = nil
    tj_visible_enemies_dispose
  end
end
