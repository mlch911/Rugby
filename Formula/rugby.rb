class Rugby < Formula
  desc "🏈 Cache CocoaPods for faster rebuild and indexing Xcode project"
  homepage "https://github.com/swiftyfinch/Rugby"
  version "1.30.7"
  url "https://github.com/swiftyfinch/Rugby/releases/download/#{version}/rugby.zip"

  def install
    bin.install Dir["bin/*"]
  end
end
