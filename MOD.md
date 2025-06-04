# README
- Core: https://github.com/rime/librime
  - download: https://rime.im/download/
- GUI: 
  - macOS: https://github.com/rime/squirrel
    - brew install --cask squirrel
  - Windows: https://github.com/rime/weasel
    - scoop install weaseal
  - iOS: Hamster
  - Android
- Schema: 
  - https://github.com/amzxyz/rime_wanxiang
  - https://github.com/iDvel/rime-ice
- Octagram: https://github.com/amzxyz/RIME-LMDG
- Fonts(macOS)
  - brew install font-noto-sans-cjk-sc
  - brew install fontconfig
    - fc-cache -frv

# Configuration
> for user dicts/prefs sync
- installation.yaml
  - iOS: Hamster
    - installation_id: "Hamster-CsHeng's-iPhone-15-Pro"
    - sync_dir: "/private/var/mobile/Library/Mobile Documents/iCloud~dev~fuxiao~app~hamsterapp/Documents/RIME/Rime/sync"
  - macOS: Squirel
    - installation_id: "Squirrel-CsHeng's-Macbook-M1-Max"
    - sync_dir: "/Users/CsHeng/Library/Mobile Documents/iCloud~dev~fuxiao~app~hamsterapp/Documents/RIME/Rime/sync"
    - ln -s "/Users/CsHeng/Library/Mobile Documents/iCloud~dev~fuxiao~app~hamsterapp/Documents/RIME/Rime" ~/Library/Rime
  - Win: Weasel
    - installation_id: "Weasel-CsHeng's-PC"
    - sync_dir: "./sync"
      - macOS/Win via syncthing
      - link syncthing shared dir to ./sync

# Ref Docs
- https://dvel.me/posts/rime-ice/
- https://www.mintimate.cc/zh/guide/installRime.html
- https://xishansnow.github.io/posts/41ac964d.html