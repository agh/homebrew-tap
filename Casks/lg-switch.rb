cask "lg-switch" do
  version "7.49,CRcfh9LFQGsj8IVs0iLKjg"
  sha256 "514b868f055af939f96c07c0b6e3a25ce2c8152d4c823b9a894691131b45a925"

  url "https://gscs-b2c.lge.com/downloadFile?fileId=#{version.csv.second}"
  name "LG Switch"
  desc "Monitor controls, screen layouts, and work and life modes for LG displays"
  homepage "https://www.lg.com/us/support/monitors"

  livecheck do
    url "https://www.lg.com/us/support/product/lg-27US500-W.AUS?tab=1"
    regex(/Mac[._-]LGSwitch[._-]v?(\d+(?:\.\d+)+)\.zip/i)
    strategy :page_match do |page, regex|
      json_string = page[/NEXT[._-]DATA[^>]*>\s*([^<]+)\s*</i, 1]
      next unless json_string

      json = Homebrew::Livecheck::Strategy::Json.parse_json(json_string)
      json.dig("props", "pageProps", "softwareData", "fileData")&.flat_map do |_, files|
        files.filter_map do |file|
          match = file["originalFileName"]&.match(regex)
          next unless match

          file_id = file["fileName"]
          next unless file_id

          "#{match[1]},#{file_id}"
        end
      end
    end
  end

  depends_on macos: :sequoia

  pkg "Switch_V#{version.csv.first}_signed.pkg"

  uninstall launchctl:  "com.lgsi.SwitchAppAgent",
            quit:       [
              "com.lgsi.LGSwitchAutoLaunchHelper",
              "com.lgsi.SwitchAppMac",
              "com.LGSI.SwitchAppMultiMonitor",
            ],
            login_item: [
              "LG Switch Multi Monitor",
              "LG Switch",
              "LGSwitchAutoLaunchHelper",
            ],
            pkgutil:    [
              "^com\\.switch\\.Fonts\\.pkg$",
              "^com\\.Switch_Directory\\.pkg$",
              "^com\\.Switch_Library\\.pkg$",
              "^com\\.SwitchApp\\.pkg$",
              "^com\\.SwitchMultiMonitor\\.pkg$",
              "^com\\.uninstallLGSwitch\\.pkg$",
            ],
            delete:     [
              "/Library/LGSwitch",
              "/usr/local/switch",
            ]

  zap trash: "~/Library/LG Switch"

  caveats do
    reboot
  end
end
