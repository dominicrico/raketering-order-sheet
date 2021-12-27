description 'Racketering Order Sheet'
author 'MMenistr'
version '1.0.0'

fx_version 'cerulean'

game 'gta5'

client_scripts {
  "@NativeUI/NativeUI.lua",
  'client/main.lua',
}

server_scripts {
  'server/main.lua',
}

shared_scripts {
  'config.lua',
}

ui_page 'html/ui.html'

files {
  'html/listener.js',
  'html/css/app.css',
  'html/paper.png',
  'html/stiefel.png',
  'html/Beyond Infinity.ttf',
  'html/ui.html',
}
