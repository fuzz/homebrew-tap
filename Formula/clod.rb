class Clod < Formula
  desc "Project file manager for Claude AI integrations"
  homepage "https://github.com/fuzz/clod"
  url "https://hackage.haskell.org/package/clod-0.1.3/clod-0.1.3.tar.gz"
  # Calculate the SHA256 with:
  # curl -sL https://hackage.haskell.org/package/clod-0.1.3/clod-0.1.3.tar.gz | shasum -a 256
  sha256 "426a90b4f4726f4ff5e477d0b4c874cb24d55a9b7bd62ac132f0db3573088a43"
  license "MIT"
  
  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  depends_on "libmagic"
  depends_on "xxhash" => :build
  depends_on "pandoc" => :recommended

  def install
    system "cabal", "v2-update"
    
    # Use allow-newer flag to work around template-haskell version incompatibility
    system "cabal", "v2-install", "--disable-tests", "--allow-newer=template-haskell", 
           "--lib", "--program-suffix=", "--installdir=#{bin}", "exe:clod"
    
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
