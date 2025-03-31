class Clod < Formula
  desc "Project file manager for Claude AI integrations"
  homepage "https://github.com/fuzz/clod"
  url "https://hackage.haskell.org/package/clod-0.1.2/clod-0.1.2.tar.gz"
  # Calculate the SHA256 with:
  # curl -sL https://hackage.haskell.org/package/clod-0.1.2/clod-0.1.2.tar.gz | shasum -a 256
  sha256 "a09b80ca5b059188cdbaedb6445104275dc406d66180e087602f3665adccfb77"
  license "MIT"
  
  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  depends_on "libmagic"
  depends_on "xxhash" => :build
  depends_on "pandoc" => :recommended

  def install
    system "cabal", "v2-update"
    # Only install the main executable, not test programs
    system "cabal", "v2-install", "--lib", "--bindir=#{bin}", "--program-suffix=", 
           "--installdir=#{bin}", "exe:clod"
    
    # Generate man pages directly during installation
    if build.with? "pandoc"
      system "bin/generate-man-pages.sh", "#{buildpath}/brew_man"
      man1.install "brew_man/man1/clod.1"
      man7.install "brew_man/man7/clod.7" 
      man8.install "brew_man/man8/clod.8"
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
    # Test if man pages are correctly installed
    system "man", "-w", "clod"
  end
end
