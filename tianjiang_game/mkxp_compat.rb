# Compatibility shim for the Android RGSS runtime.
# The game's optional keyboard/IME helpers use Win32-only libraries.
# Replace Win32API with a safe no-op implementation before the game
# scripts are executed. Standard RPG Maker input still works.
if defined?(Win32API)
  Object.send(:remove_const, :Win32API)
end

class Win32API
  def initialize(dll, func, *args)
    @func = func.to_s
  end

  def call(*args)
    case @func
    when 'GetPrivateProfileString', 'GetWndText',
         'MultiByteToWideChar', 'WideCharToMultiByte'
      ''
    else
      0
    end
  end
  alias Call call
end
