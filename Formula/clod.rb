# frozen_string_literal: true

class Clod < Formula
  desc 'Project file manager for Claude AI integrations'
  homepage 'https://github.com/fuzz/clod'
  url "https://hackage.haskell.org/package/clod-0.1.38/clod-0.1.38.tar.gz" # TARBALL_URL_MARKER
  sha256 "b99a753254d69ff051a102551bb1e80c5ba311d7642e711fe0ef38a3af849915" # TARBALL_SHA256_MARKER
  license 'MIT'

  # Bottle specification - will be filled in after bottle creation
  bottle do
    root_url "https://github.com/fuzz/clod/releases/download/v0.1.38" # BOTTLE_ROOT_URL_MARKER
    rebuild 9
    sha256 cellar: :any, arm64_sequoia: "c0d987c97dce51854af9a0321f0050bdcfcd169b7e0e4f71f5e08997fb408f45" # BOTTLE_SHA256_MARKER
    
    # Add other platform/OS combinations as needed
    # sha256 cellar: :any, sequoia: "INTEL_SHA_PLACEHOLDER"
  end

  depends_on 'cabal-install' => :build
  depends_on 'ghc' => :build
  depends_on 'libmagic'
  depends_on 'pkg-config' => :build
  depends_on 'xxhash' => :build
  depends_on 'pandoc' => :recommended

  def install
    # Create a dynamic cabal.project.local to use Homebrew's libmagic
    libmagic = Formula['libmagic']
    (buildpath/"cabal.project.local").write <<~EOS
      allow-newer: template-haskell
      package magic
        extra-include-dirs: #{libmagic.opt_include}
        extra-lib-dirs: #{libmagic.opt_lib}
        flags: +pkgconfig
    EOS

    system 'cabal', 'v2-update'
    
    # Add pkg-config path for libmagic
    ENV.prepend_path 'PKG_CONFIG_PATH', libmagic.opt_lib/'pkgconfig'
    
    # Set LDFLAGS to ensure proper linking to libmagic
    ENV.append 'LDFLAGS', "-L#{libmagic.opt_lib} -lmagic"
    
    # Use Homebrew's standard Cabal v2 arguments for a more reliable installation
    # Include allow-newer flag to work around template-haskell version incompatibility
    system 'cabal', 'v2-install', *std_cabal_v2_args, '--allow-newer=template-haskell', 'exe:clod'
    
    # Ensure the executable can find libmagic at runtime
    if File.exist?(bin/"clod")
      system "install_name_tool", "-change", 
             "/usr/local/lib/libmagic.dylib", 
             "#{libmagic.opt_lib}/libmagic.dylib", 
             "#{bin}/clod"
    end

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
