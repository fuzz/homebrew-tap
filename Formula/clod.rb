# frozen_string_literal: true

class Clod < Formula
  desc 'Project file manager for Claude AI integrations'
  homepage 'https://github.com/fuzz/clod'
  url "https://hackage.haskell.org/package/clod-0.1.34/clod-0.1.34.tar.gz" # TARBALL_URL_MARKER
  sha256 "4ca988af99de00d71a47ef82d03dca5d11c97158f0f3ef3cd2eeaa1ce2d6db3c" # TARBALL_SHA256_MARKER
  license 'MIT'

  # Bottle specification - will be filled in after bottle creation
  bottle do
    root_url "https://github.com/fuzz/clod/releases/download/v0.1.34" # BOTTLE_ROOT_URL_MARKER
    rebuild 6
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5ba8411758e26c8ed09ebceba01a3a8bf013054294828bdb96dac02e954522b6" # BOTTLE_SHA256_MARKER
    
    # Add other platform/OS combinations as needed
    # sha256 cellar: :any, sequoia: "INTEL_SHA_PLACEHOLDER"
  end

  depends_on 'cabal-install' => :build
  depends_on 'ghc' => :build
  depends_on 'libmagic'
  depends_on 'xxhash' => :build
  depends_on 'pandoc' => :recommended

  def install
    system 'cabal', 'v2-update'

    # Use Homebrew's standard Cabal v2 arguments for a more reliable installation
    # Include allow-newer flag to work around template-haskell version incompatibility
    system 'cabal', 'v2-install', *std_cabal_v2_args, '--allow-newer=template-haskell', 'exe:clod'

    # Install man pages directly from source
    return unless build.with? 'pandoc'

    # Generate man pages directly with pandoc
    if File.exist?("#{buildpath}/man/clod.1.md")
      system 'pandoc', '-s', '-t', 'man', "#{buildpath}/man/clod.1.md", '-o', "#{buildpath}/clod.1"
      man1.install "#{buildpath}/clod.1" if File.exist?("#{buildpath}/clod.1")
    end

    if File.exist?("#{buildpath}/man/clod.7.md")
      system 'pandoc', '-s', '-t', 'man', "#{buildpath}/man/clod.7.md", '-o', "#{buildpath}/clod.7"
      man7.install "#{buildpath}/clod.7" if File.exist?("#{buildpath}/clod.7")
    end

    return unless File.exist?("#{buildpath}/man/clod.8.md")

    system 'pandoc', '-s', '-t', 'man', "#{buildpath}/man/clod.8.md", '-o', "#{buildpath}/clod.8"
    man8.install "#{buildpath}/clod.8" if File.exist?("#{buildpath}/clod.8")
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
    assert_match 'Clod - Project file manager for Claude AI', shell_output("#{bin}/clod --help")

    # Only test man pages if they should be installed
    if build.with? 'pandoc'
      begin
        system 'man', '-w', 'clod'
      rescue StandardError
        nil
      end
    end
  end
end
