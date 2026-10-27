cask "insta360-wave-controller" do
  version "1.1.0,build7,_20261008_101106_signed_1791425478377,85661444411946edb17399282f5b0683"
  sha256 "f63958145e6d658a0296f6232c7776712f7dc525d85da11f5d632df49fd2fe1d"

  url "https://wassets.insta360.com/common/#{version.csv.last}/Insta360WaveController_#{version.csv.first}(#{version.csv.second})#{version.csv.third}.pkg"
  name "Insta360 Wave Controller"
  desc "Desktop app for managing Insta360 Wave speakerphones"
  homepage "https://www.insta360.com/download/insta360-wave",
           browsed: "2026-10-27"

  livecheck do
    url "https://openapi.insta360.com/app/appDownload/getGroupApp?group=insta360-wave&X-Language=en-us"
    regex(%r{/(\h+)/Insta360WaveController[._-]v?(\d+(?:\.\d+)+)\((build\d+)\)([^/]+)\.pkg}i)
    strategy :json do |json, regex|
      app = json.dig("data", "apps")&.find { |item| item["app_id"] == 144 }
      next unless app

      official = app["items"]&.filter_map do |item|
        next if item["platform"] != "mac"

        channel = item["channels"]&.find { |c| c["channel"] == "official" }
        [item, channel] if channel
      end
      _, channel = official&.max_by { |item, _| Version.new(item["version"]) }
      next unless channel

      match = channel["download_url"]&.match(regex)
      next unless match

      "#{match[2]},#{match[3]},#{match[4]},#{match[1]}"
    end
  end

  auto_updates true
  depends_on :macos

  pkg "Insta360WaveController_#{version.csv.first}(#{version.csv.second})#{version.csv.third}.pkg"

  uninstall launchctl: "com.insta360.Wavecontroller",
            quit:      "com.insta360.Wavecontroller",
            pkgutil:   "^com\\.insta360\\.Psp$"

  zap trash: [
    "~/Library/Application Support/Insta360 Wave Controller",
    "~/Library/Application Support/Insta360/Insta360 Wave Controller",
  ]
end
