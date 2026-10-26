cask "input" do
  version "1.0.2"
  sha256 "f892ecd1d144747272e8a5b703bf85e1b22ba9306b4067eee6f6871fc1702f11"

  url "https://github.com/worklouder/input-releases/releases/download/v#{version}/input-#{version}-arm64.dmg"
  name "Input"
  desc "Configurator for Work Louder keyboards and macro pads"
  homepage "https://worklouder.cc/input"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :monterey

  app "input.app", target: "Input.app"
end
