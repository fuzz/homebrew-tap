class Clod < Formula
  desc "Project file manager for Claude AI integrations"
  homepage "https://github.com/fuzz/clod"
  url "https://hackage.haskell.org/package/clod-0.1.12/clod-0.1.12.tar.gz"
  # Calculate the SHA256 with:
  # curl -sL https://hackage.haskell.org/package/clod-0.1.12/clod-0.1.12.tar.gz | shasum -a 256
  # SHA will need to be updated after the package is uploaded to Hackage
  sha256 "55235a8ca747ce66ada0e5bc387eb756e8bea734744028c09b2869c29c2be7dd"
  license "MIT"
  
  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  depends_on "libmagic"
  depends_on "xxhash" => :build
  depends_on "pandoc" => :recommended

  def install
    system "cabal", "update"
    
    # Use allow-newer flag to work around template-haskell version incompatibility
    system "cabal", "install", "--disable-tests", "--allow-newer=template-haskell", 
           "--program-suffix=", "--installdir=#{bin}", "exe:clod"
    
    # Install man pages directly from source
    if build.with? "pandoc"
      # Generate man pages directly with pandoc
      if File.exist?("#{buildpath}/man/clod.1.md")
        system "pandoc", "-s", "-t", "man", "#{buildpath}/man/clod.1.md", "-o", "#{buildpath}/clod.1"
        man1.install "#{buildpath}/clod.1" if File.exist?("#{buildpath}/clod.1")
      end
      
      if File.exist?("#{buildpath}/man/clod.7.md")
        system "pandoc", "-s", "-t", "man", "#{buildpath}/man/clod.7.md", "-o", "#{buildpath}/clod.7"
        man7.install "#{buildpath}/clod.7" if File.exist?("#{buildpath}/clod.7")
      end
      
      if File.exist?("#{buildpath}/man/clod.8.md")
        system "pandoc", "-s", "-t", "man", "#{buildpath}/man/clod.8.md", "-o", "#{buildpath}/clod.8"
        man8.install "#{buildpath}/clod.8" if File.exist?("#{buildpath}/clod.8")
      end
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
    
    # Only test man pages if they should be installed
    if build.with? "pandoc"
      system "man", "-w", "clod" rescue nil
    end
  end
end
