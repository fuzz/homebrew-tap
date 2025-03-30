class Clod < Formula
  desc "Project file manager for Claude AI integrations"
  homepage "https://github.com/fuzz/clod"
  url "https://github.com/fuzz/clod/archive/refs/tags/v0.1.0.tar.gz"
  # After creating the GitHub release, calculate the SHA256 with:
  # curl -L https://github.com/fuzz/clod/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256
  sha256 "REPLACE_WITH_ACTUAL_SHA256_AFTER_RELEASE"
  license "MIT"
  
  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  depends_on "libmagic"
  depends_on "pandoc" => :recommended

  def install
    system "cabal", "v2-update"
    system "cabal", "v2-install", *std_cabal_v2_args
    
    # Generate man pages if pandoc is available
    if build.with? "pandoc"
      system "bin/generate-man-pages.sh"
      man1.install "man/clod.1"
      man7.install "man/clod.7"
      man8.install "man/clod.8"
    end
  end

  def caveats
    <<~EOS
      Clod outputs the path to the staging directory, which you can use with:
      
      # On macOS, open the staging directory in Finder:
        open `clod [options]`
      
      # For scripts, you can capture the output:
        STAGING_DIR=$(clod [options])
        open "$STAGING_DIR"
    EOS
  end

  test do
    assert_match "Clod - Project file manager for Claude AI", shell_output("#{bin}/clod --help")
  end
end